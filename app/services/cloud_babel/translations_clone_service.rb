=begin

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end

module CloudBabel
    class TranslationsCloneService


        # IMPORTANT: This is a modified copy of the SynchronizationService
        # please be careful modifying this file
        def self.remote_clone instance_code=nil

            instance_name = instance_code.camelize
            instance_code = instance_code.gsub("_","-")


            # synchronization server url
            host = "http://localhost:8080"
            host = "https://server.raven.dev.gt"


            return LC::Response.service(false, "no valid instance code provided") if instance_code.blank?


            api_endpoint = "#{host}/api/bucket/babel-#{instance_code}/documents"


            # get last sync data
            response = Faraday.get(api_endpoint+"?last=1")
            response = FastJsonparser.parse(response.body)
            response = response[:data][:documents][0]


            # if first time sync
            return LC::Response.service(false, "no strings found") if response.blank?


            # add new modules
            response[:modules].each do |babel_module|
                next if babel_module[:name].blank?

                # we do not want to clone strings from builder engines
                next if babel_module[:name] == instance_name

                platform = babel_module[:platform]
                platform = "rails_engine"   if babel_module[:name].start_with?("Cloud")
                platform = "rails_core"     if babel_module[:name] == "Core"

                local_module = CloudBabel::Module
                .create_with({
                    created_at: babel_module[:created_at],
                    platform: babel_module[:platform]
                }).find_or_create_by({ name: babel_module[:name] })

                local_module.platform = platform
                local_module.updated_at = DateTime.now
                local_module.save

            end

            # working with buckets
            babel_reference_modules = {}

            response[:buckets].each do |babel_bucket|

                next if babel_bucket[:name].blank?

                # we do not want to clone strings from builder engines
                next if babel_bucket[:reference_module] == instance_name

                # reference to modules that buckets belongs to
                # this reference as string is necessary because the id of the module can change
                # between synchronizations, thats why we search for the id of the module every time
                if babel_reference_modules[babel_bucket[:reference_module]].blank?
                    babel_reference_modules[babel_bucket[:reference_module]] =
                    CloudBabel::Module.find_by(name: babel_bucket[:reference_module])
                end

                # add new bucket
                CloudBabel::Bucket
                .create_with({
                    created_at: babel_bucket[:created_at],
                    module: babel_reference_modules[babel_bucket[:reference_module]]
                }).find_or_create_by({
                    name: babel_bucket[:name],
                    reference_module: babel_bucket[:reference_module]
                })

            end

            # · working with strings
            babel_reference_buckets = {}

            response[:strings].each do |remote_string|
                # reference to modules that buckets belongs to
                # this reference as string is necessary because the id of the module or bucket can change
                # between synchronizations, thats why we search for the id of the module every time
                if babel_reference_buckets[remote_string[:reference_bucket]].blank?
                    remote_string[:reference_bucket] ||= remote_string[:reference_module_bucket]
                    babel_reference_buckets[remote_string[:reference_bucket]] = 
                    CloudBabel::Bucket.find_by(
                        name: remote_string[:reference_bucket].split("-")[1],
                        reference_module: remote_string[:reference_bucket].split("-")[0]
                    )
                end

                # Do not sync labes that do not have a valid module and bucket reference
                next if babel_reference_buckets[remote_string[:reference_bucket]].blank?

                # we do not want to clone strings from builder engines
                next if babel_reference_buckets[remote_string[:reference_bucket]].reference_module == instance_name
            
                remote_string_reference = "#{babel_reference_buckets[remote_string[:reference_bucket]].reference_module}-#{babel_reference_buckets[remote_string[:reference_bucket]].name}"

                # add new string if it does not exist
                local_string = CloudBabel::String.with_deleted.create_with({
                    context: remote_string[:context],
                    es: remote_string[:es],
                    en: remote_string[:en],
                    de: remote_string[:de],
                    status: remote_string[:status],
                    need_help: remote_string[:need_help],
                    need_translation: remote_string[:need_translation],
                    last_update_context: remote_string[:last_update_context],
                    last_update_es: remote_string[:last_update_es],
                    last_update_en: remote_string[:last_update_en],
                    last_update_de: remote_string[:last_update_de],
                    last_update_fr: remote_string[:last_update_fr],
                    last_update_status: remote_string[:last_update_status],
                    created_at: remote_string[:created_at],
                    updated_at: remote_string[:updated_at],
                    deleted_at: remote_string[:deleted_at],
                    bucket: babel_reference_buckets[remote_string[:reference_bucket]]
                }).find_or_create_by({
                    label: remote_string[:label],
                    reference_module_bucket: remote_string_reference
                })

            end

            LC::Response.service true

        end

    end
end

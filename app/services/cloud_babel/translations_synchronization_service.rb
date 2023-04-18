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
    class TranslationsSynchronizationService

        # IMPORTANT: If you modify this file please check the CloneService that contains a modified
        # copy of this synchronization code
        def self.remote_sync double_way_sync=false

            host = "http://localhost:8080"
            host = "https://api.datenbanken.dev/v2"
            instance_code = LC::System::Info.instance[:code].gsub("_","-")
            instance_code = "test4"

            # if special namespace is configured in the lesli.yml settings
            # this is useful when we need install an instance and customize
            # the translations for a client
            #instance_code = Rails.application.config.lesli.dig(:configuration, :babel, :namespace)

            api_endpoint = "#{host}/buckets/#{instance_code}-babel/documents"


            # get last sync data
            response = Faraday.get("#{api_endpoint}/last")
            response = FastJsonparser.parse(response.body)
            response = response[:documents][0]


            # if first time sync
            response = FastJsonparser.parse({ modules: [], buckets: [], strings: [] }.to_json) if response.blank?

            # add new modules
            response[:modules].each do |babel_module|
                next if babel_module[:name].blank?

                local_module = CloudBabel::Module
                .create_with({
                    created_at: babel_module[:created_at],
                    platform: babel_module[:platform]
                }).find_or_create_by({ name: babel_module[:name] })

                platform = babel_module[:platform]
                platform = "rails_engine"   if babel_module[:name].start_with?("Cloud")
                platform = "rails_core"     if babel_module[:name] == "Core"
                platform = "rails_builder"  if ["MitwerkenCloud", "DeutscheLeibrenten", "LesliCloud"].include?(babel_module[:name])

                local_module.platform = platform
                local_module.updated_at = DateTime.now
                local_module.save

            end

            # working with buckets
            babel_reference_modules = {}

            response[:buckets].each do |babel_bucket|

                next if babel_bucket[:name].blank?

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
            
                remote_string_reference = "#{babel_reference_buckets[remote_string[:reference_bucket]].reference_module}-#{babel_reference_buckets[remote_string[:reference_bucket]].name}"

                # add new string if it does not exist
                local_string = CloudBabel::String.with_deleted.create_with({
                    bucket: babel_reference_buckets[remote_string[:reference_bucket]]
                }).find_or_create_by({
                    label: remote_string[:label],
                    reference_module_bucket: remote_string_reference
                })

                # if status changed
                if remote_string[:status] != local_string["status"]

                    remote_string[:last_update_status] = Time.now if remote_string[:last_update_status].blank?
                    local_string["last_update_status"] = Time.now if local_string["last_update_status"].blank?

                    # check if remote is newer than local
                    if (remote_string[:last_update_status] > local_string["last_update_status"])

                        # if so, update local translation with the incoming
                        local_string["status"] = remote_string[:status]
                        local_string["last_update_status"] = remote_string[:last_update_status]

                    end

                end

                # if context changed
                if remote_string[:context] != local_string["context"]

                    remote_string[:last_update_context] = Time.now if remote_string[:last_update_context].blank?
                    local_string["last_update_context"] = Time.now if local_string["last_update_context"].blank?

                    # check if remote is newer than local
                    if (remote_string[:last_update_context] > local_string["last_update_context"])

                        # if so, update local translation with the incoming
                        local_string["context"] = remote_string[:context]
                        local_string["last_update_context"] = remote_string[:last_update_context]

                    end

                end

                # check if necessary to update any translation
                # due babel can work as client and server at the same time, we have to synchronize labels for all supported languages
                I18n.available_locales.each do |locale|

                    remote_time = Time.parse remote_string[:"last_update_#{locale}"] rescue Time.now.getutc
                    local_time = Time.parse local_string["last_update_#{locale}"] rescue Time.parse("Jan 1900")

                    # if translation changed
                    if local_string[locale] != remote_string[:"#{locale}"]
            
                        # check if remote is newer than local
                        if (remote_time > local_time)
            
                            # if so, update local translation with the incoming
                            local_string[locale] = local_time
                            local_string["last_update_#{locale}"] = remote_time

                        end
            
                    end
                    
                end

                local_string.save

            end

            return LC::Response.service(true) if double_way_sync == false

            # · Collect modules, buckets and strings for syncronization

            # get and parse modules
            modules = CloudBabel::Module.all.map do |babel_module|
                babel_module.as_json
            end

            # get and parse buckets
            buckets = CloudBabel::Bucket.all.map do |babel_bucket|
                babel_bucket.as_json
            end

            # get and parse strings including the deleted ones
            strings = CloudBabel::String.with_deleted.all.map do |babel_string|
                babel_string.as_json
            end

            # send latest translation to raven
            #response = Faraday.post(api_endpoint, ({ modules: modules, buckets: buckets, strings: strings }).to_json, "Content-Type" => "application/json")

            LC::Response.service true

        end

    end
end

=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end

require_dependency "cloud_babel/application_controller"

module CloudBabel
    class TranslationsController < ApplicationController
        before_action :set_translation, only: []

        # GET /translations
        def index
            @translations = Translation.all
        end

        # GET /translations/1
        def show
        end

        # GET /translations/new
        def new
            @translation = Translation.new
        end

        # GET /translations/1/edit
        def edit
        end

        # POST /translations
        def create
            @translation = Translation.new(translation_params)

            if @translation.save
                redirect_to @translation, notice: 'Translation was successfully created.'
            else
                render :new
            end
        end

        # PATCH/PUT /translations/1
        def update
            if @translation.update(translation_params)
                redirect_to @translation, notice: 'Translation was successfully updated.'
            else
                render :edit
            end
        end

        # DELETE /translations/1
        def destroy
            @translation.destroy
            redirect_to translations_url, notice: 'Translation was successfully destroyed.'
        end

        def build

            clean

            files = { }

            Translation.locales.each do |lang|
                files[ lang[0] ] = { }
            end
    
            #CloudBabel::Translation::String.where(status: 1).each do |string|
            Translation::String.all.each do |string|
    
                module_name = string.bucket.module.name
                bucket_name = string.bucket.name
    
                module_name_sym = module_name.downcase.sub('cloud', '')
    
                Translation.locales.each do |lang|

                    lang = lang[0]
    
                    file_path = Rails.root.join("config", "locales", bucket_name, "#{ bucket_name.gsub('/','_') }.#{ lang }.yml")
    
                    if module_name != "Core"
                        file_path = Rails.root.join("engines", module_name, "config", "locales", bucket_name, "#{ bucket_name.gsub('/','_') }.#{ lang }.yml")
                    end
    
                    file_id = file_path.to_s.to_sym
    
                    unless files[lang].has_key? file_id
                        files[lang][file_id] = { }
                    end
    
                    unless files[lang][file_id].has_key? module_name_sym
                        files[lang][file_id][module_name_sym] = { }
                    end
    
                    unless files[lang][file_id][module_name_sym].has_key? bucket_name
                        files[lang][file_id][module_name_sym][bucket_name] = { }
                    end
    
                    files[lang][file_id][module_name_sym][bucket_name][string.label] = string[lang]
    
                end
    
            end
    
            files.each do |file_by_language|
    
                lang = file_by_language[0]
                file_by_class = file_by_language[1]
    
                file_by_class.each do |file|
    
                    file_path = file[0].to_s
                    translations = file[1]
    
                    # creates folder and subfolders
                    FileUtils.makedirs(File.dirname(file_path))
    
                    # creates translation file for every available language
                    translation_file = File.new(file_path, "w+")
    
                    translation_file.write({ "#{lang}": translations}.to_yaml)
    
                    translation_file.close

                    p "file added: #{ file_path }"
        
                end
    
            end

            responseWithSuccessful()

        end

        def synchronization
            host = "https://server.raven.dev.gt"
            #host = "http://localhost:8888"

            # get last sync data
            response = Faraday.get("#{host}/api/bucket/cloud-babel-dl/documents?last=1")
            response = JSON.parse(response.body)

            puts "";puts "";puts "";puts "";puts "";
            p response['data']
            puts "";puts "";puts "";puts "";puts "";

            response = response['data']['rows'][0]


            # if first time sync
            response = JSON.parse({modules: [], buckets: [], strings: [] }.to_json) if response.blank?


            # add new modules
            response['modules'].each do |babel_module|
                CloudBabel::Translation::Module
                .create_with(created_at: babel_module['created_at'])
                .find_or_create_by({ name: babel_module['name'] })
            end

            # working with buckets
            babel_reference_modules = {}
            response['buckets'].each do |babel_bucket|

                # reference to modules that buckets belongs to
                if babel_reference_modules[babel_bucket['reference_module']].blank?
                    babel_reference_modules[babel_bucket['reference_module']] = 
                    CloudBabel::Translation::Module.find_by(name: babel_bucket['reference_module'])
                end

                # add new bucket
                CloudBabel::Translation::Bucket
                .create_with({
                    created_at: babel_bucket['created_at'],
                    module: babel_reference_modules[babel_bucket['reference_module']]
                }).find_or_create_by({
                    name: babel_bucket['name'], 
                    reference_module: babel_bucket['reference_module'] 
                })

            end

            # working with strings
            babel_reference_buckets = {}
            response['strings'].each do |remote_string|

                # reference to modules that buckets belongs to
                if babel_reference_buckets[remote_string['reference_bucket']].blank?
                    babel_reference_buckets[remote_string['reference_bucket']] = 
                    CloudBabel::Translation::Bucket.find_by(
                        name: remote_string['reference_bucket'].split('-')[1],
                        reference_module: remote_string['reference_bucket'].split('-')[0]
                    )
                end
            
                remote_string_reference = "#{babel_reference_buckets[remote_string['reference_bucket']].module.name}-#{babel_reference_buckets[remote_string['reference_bucket']].name}"
            
                # add new string if it does not exist
                local_string = CloudBabel::Translation::String
                .create_with({
                    context: remote_string['context'],
                    es: remote_string['es'],
                    en: remote_string['en'],
                    de: remote_string['de'],
                    status: remote_string['status'],
                    last_update_context: remote_string['last_update_context'],
                    last_update_es: remote_string['last_update_es'],
                    last_update_en: remote_string['last_update_en'],
                    last_update_de: remote_string['last_update_de'],
                    last_update_fr: remote_string['last_update_fr'],
                    last_update_status: remote_string['last_update_status'],
                    created_at: remote_string['created_at'],
                    bucket: babel_reference_buckets[remote_string['reference_bucket']]
                }).find_or_create_by({
                    label: remote_string['label'], 
                    reference_bucket: remote_string_reference
                })
            
                # if status changed
                if remote_string["status"] != local_string["status"]

                    # check if remote is newer than local
                    if (remote_string["last_update_status"] > 
                        local_string["last_update_status"])

                        # if so, update local translation with the incoming
                        local_string["status"] = remote_string["status"]
                        local_string["last_update_status"] = remote_string["last_update_status"]

                    end

                end

                # if context changed
                if remote_string["context"] != local_string["context"]

                    # check if remote is newer than local
                    if (remote_string["last_update_context"] > 
                        local_string["last_update_context"])

                        # if so, update local translation with the incoming
                        local_string["context"] = remote_string["context"]
                        local_string["last_update_context"] = remote_string["last_update_context"]

                    end

                end


                # check if necessary to update any translation
                Translation.locales.each do |locale|
            
                    locale = locale[0]
            
                    # if translation changed
                    if local_string[locale] != remote_string[locale]
            
                        # check if remote is newer than local
                        if (remote_string["last_update_#{locale}"] > 
                            local_string["last_update_#{locale}"])
            
                            # if so, update local translation with the incoming
                            local_string[locale] = remote_string[locale]
                            local_string["last_update_#{locale}"] = remote_string["last_update_#{locale}"]

                        end
            
                    end
                    
                end

                local_string.save!
            
            end

            # get and parse modules
            modules = CloudBabel::Translation::Module.all.map do |babel_module|
                babel_module.as_json
            end

            # get and parse buckets
            buckets = CloudBabel::Translation::Bucket.all.map do |babel_bucket|
                babel_bucket.as_json
            end

            # get and parse strings
            strings = CloudBabel::Translation::String.all.map do |babel_string|
                babel_string.as_json
            end

            # send latest translation to raven
            response = Faraday.post("#{host}/api/bucket/cloud-babel-dl/documents", 
                ({ modules: modules, buckets: buckets, strings: strings }).to_json,
                "Content-Type" => "application/json"
            )

            responseWithSuccessful()

        end

        private

        def clean
            Lesli::engines.each do |engine|
                engine_path = Rails.root.join("engines", engine["name"], "config", "locales")
                FileUtils.rm_rf(engine_path)
            end
            engine_path = Rails.root.join("config", "locales")
            FileUtils.rm_rf(engine_path)
        end

        # Use callbacks to share common setup or constraints between actions.
        def set_translation
            @translation = Translation.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_params
            params.fetch(:translation, {})
        end
    end
end

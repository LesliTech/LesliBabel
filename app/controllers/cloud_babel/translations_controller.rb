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

Lesli - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  <hello@lesli.tech>
@website  <https://lesli.tech>
@license  Propietary - all rights reserved.

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
                redirect_to @translation, notice: "Translation was successfully created."
            else
                render :new
            end
        end

        # PATCH/PUT /translations/1
        def update
            if @translation.update(translation_params)
                redirect_to @translation, notice: "Translation was successfully updated."
            else
                render :edit
            end
        end

        # DELETE /translations/1
        def destroy
            @translation.destroy
            redirect_to translations_url, notice: "Translation was successfully destroyed."
        end

        def options
            respond_with_successful({
                locales_available: Rails.application.config.lesli_settings["configuration"]["locales_available"]
            })
        end

        def build
        end

        def deploy

            do_clean

            files = { }

            available_locales = Rails.application.config.lesli_settings["configuration"]["locales"]

            available_locales.each do |lang|
                files[lang] = { }
            end

            Translation::String.all.each do |string|
    
                module_type = string.bucket.module.module_type
                module_name = string.bucket.module.name
                bucket_name = string.bucket.name

                # build translation files for rails applications only
                next unless ["rails_engine", "rails_core"].include? module_type

                module_name_sym = module_name.downcase.sub("cloud", "")
    
                available_locales.each do |lang|
    
                    file_path = Rails.root.join("config", "locales", bucket_name, "#{ bucket_name.gsub("/","_") }.#{ lang }.yml")

                    # prepend engine path when building translations for engines
                    if module_type == "rails_engine"
                        file_path = Rails.root.join("engines", module_name, "config", "locales", bucket_name, "#{ bucket_name.gsub("/","_") }.#{ lang }.yml")
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
    
                    # send debug message for missing translations
                    string[lang] = ":" + string.path + ":" if string[lang].blank?

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

            logger.debug "/babel/translation"
            logger.debug system "bundle exec rake i18n:js:export RAILS_ENV=production"

            do_restart_server if Rails.env.production?

            respond_with_successful

        end

        def synchronization

            host = "http://localhost:8080"
            host = "https://server.raven.dev.gt"
            api_endpoint = "#{host}/api/bucket/lesli-babel-dl/documents"

            # get last sync data
            response = Faraday.get(api_endpoint+"?last=1")
            response = JSON.parse(response.body)
            response = response["data"]["documents"][0]

            # if first time sync
            response = JSON.parse({modules: [], buckets: [], strings: [] }.to_json) if response.blank?

            # add new modules
            response["modules"].each do |babel_module|
                next if babel_module["name"].blank?
                CloudBabel::Translation::Module
                .create_with(created_at: babel_module["created_at"])
                .find_or_create_by({ name: babel_module["name"] })
            end

            # working with buckets
            babel_reference_modules = {}
            response["buckets"].each do |babel_bucket|

                next if babel_bucket["name"].blank?

                # reference to modules that buckets belongs to
                if babel_reference_modules[babel_bucket["reference_module"]].blank?
                    babel_reference_modules[babel_bucket["reference_module"]] = 
                    CloudBabel::Translation::Module.find_by(name: babel_bucket["reference_module"])
                end

                # add new bucket
                CloudBabel::Translation::Bucket
                .create_with({
                    created_at: babel_bucket["created_at"],
                    module: babel_reference_modules[babel_bucket["reference_module"]]
                }).find_or_create_by({
                    name: babel_bucket["name"], 
                    reference_module: babel_bucket["reference_module"] 
                })

            end

            # · working with strings
            babel_reference_buckets = {}

            response["strings"].each do |remote_string|

                # reference to modules that buckets belongs to
                if babel_reference_buckets[remote_string["reference_bucket"]].blank?
                    babel_reference_buckets[remote_string["reference_bucket"]] = 
                    CloudBabel::Translation::Bucket.find_by(
                        name: remote_string["reference_bucket"].split("-")[1],
                        reference_module: remote_string["reference_bucket"].split("-")[0]
                    )
                end
            
                remote_string_reference = "#{babel_reference_buckets[remote_string["reference_bucket"]].module.name}-#{babel_reference_buckets[remote_string["reference_bucket"]].name}"
            
                # add new string if it does not exist
                local_string = CloudBabel::Translation::String.create_with({
                    context: remote_string["context"],
                    es: remote_string["es"],
                    en: remote_string["en"],
                    de: remote_string["de"],
                    status: remote_string["status"],
                    need_help: remote_string["need_help"],
                    need_translation: remote_string["need_translation"],
                    last_update_context: remote_string["last_update_context"],
                    last_update_es: remote_string["last_update_es"],
                    last_update_en: remote_string["last_update_en"],
                    last_update_de: remote_string["last_update_de"],
                    last_update_fr: remote_string["last_update_fr"],
                    last_update_status: remote_string["last_update_status"],
                    created_at: remote_string["created_at"],
                    updated_at: remote_string["updated_at"],
                    deleted_at: remote_string["deleted_at"],
                    bucket: babel_reference_buckets[remote_string["reference_bucket"]]
                }).find_or_create_by({
                    label: remote_string["label"], 
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

                # if help request changed
                if remote_string["help_needed"] != local_string["help_needed"]

                    # check if remote is newer than local
                    if (remote_string["last_update_context"] > 
                        local_string["last_update_context"])

                        # if so, update local translation with the incoming
                        local_string["help_needed"] = remote_string["help_needed"]
                        local_string["last_update_context"] = remote_string["last_update_context"]

                    end

                end

                # check if necessary to update any translation
                Rails.application.config.lesli_settings["configuration"]["locales"] do |locale|
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

            # delete all the strings with deleted date
            CloudBabel::Translation::String.where("deleted_at is not null").destroy_all

            # · Collect modules, buckets and strings for syncronization

            # get and parse modules
            modules = CloudBabel::Translation::Module.all.map do |babel_module|
                babel_module.as_json
            end

            # get and parse buckets
            buckets = CloudBabel::Translation::Bucket.all.map do |babel_bucket|
                babel_bucket.as_json
            end

            # get and parse strings including the deleted ones
            strings = CloudBabel::Translation::String.all.map do |babel_string|
                babel_string.as_json
            end

            # send latest translation to raven
            response = Faraday.post(api_endpoint, 
                ({ modules: modules, buckets: buckets, strings: strings }).to_json,
                "Content-Type" => "application/json"
            )

            response = JSON.parse(response.body)

            response = response["successful"]

            responseWithSuccessful() if response === true

            responseWithError() if response  != true

        end

        def clean
            do_clean
            responseWithSuccessful()
        end

        def search
            
            search_string = params[:search_string]
            search_string = search_string.downcase
            search_string = search_string.gsub(" ","%")

            sql_where_condition = []

            # add filter to select only available languages 
            Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|
                sql_where_condition.push("LOWER(#{locale}) like :search_string")
            end

            sql_where_condition.push("LOWER(label) like :search_string")
            sql_where_condition.push("LOWER(context) like :search_string")

            strings = Translation::String.where(sql_where_condition.join(" OR "), { 
                search_string: "%#{search_string}%" 
            })

            strings = strings
            .page(@query[:pagination][:page])
            .per(@query[:pagination][:perPage])
            .order(:updated_at)

            respond_with_successful(LC::Response.pagination(
                strings.current_page,
                strings.total_pages,
                strings.total_count,
                strings.length,
                strings
            ))
            
        end

        def stats

            # total translations registered in babel
            total_strings = Translation::String.all.count

            # total translations by language
            total_strings_translations = []
            
            Rails.application.config.lesli_settings["configuration"]["locales_available"].each do |locale|
                total_strings_translations.push({
                    code: locale[0],
                    name: locale[1],
                    total: Translation::String.where("#{locale[0]} is not null").where("#{locale[0]} != ''").count
                })
            end

            # total translations that needs help
            total_strings_waiting_for_help = Translation::String.where(:need_help => true).count

            # total translations that needs translation
            total_strings_waiting_for_translation = Translation::String.where(:need_translation => true).count
            
            responseWithSuccessful({
                total_strings: total_strings,
                total_strings_translations: total_strings_translations,
                total_strings_waiting_for_help: total_strings_waiting_for_help,
                total_strings_waiting_for_translation: total_strings_waiting_for_translation
            })
        end

        private

        def do_clean
            Lesli::engines.each do |engine|
                engine_path = Rails.root.join("engines", engine["name"], "config", "locales")
                FileUtils.rm_rf(engine_path)
            end
            engine_path = Rails.root.join("config", "locales")
            FileUtils.rm_rf(engine_path)
        end

        def do_restart_server
            return if Rails.env != "production"
            FileUtils.touch Rails.root.join("tmp", "restart.txt")
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

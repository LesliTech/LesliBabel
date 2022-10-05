=begin

Lesli

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
    class TranslationsService

        def self.restart_server
            return if Rails.env != "production"
            system "bundle exec rake i18n:js:export RAILS_ENV=production"
            FileUtils.touch Rails.root.join("tmp", "restart.txt")
        end

        def self.clean

            # store full path to translation files for every language
            files_to_delete = []

            # remove javascript translation cache
            files_to_delete.push(Rails.root.join("public", "javascripts", "translations.js"))

            # get translation files for engines only
            Lesli::engines.each do |engine|
                files_to_delete.push(Rails.root.join("engines", engine["name"], "config", "locales"))
            end

            # include translation files for lesli core
            files_to_delete.push(Rails.root.join("config", "locales"))

            # include external app translations
            files_to_delete.push(Rails.root.join("public", "tmp", "locales"))

            # delete all the translation files found
            files_to_delete.each do |file|
                FileUtils.rm_rf(file)
            end

            LC::Response.service true, files_to_delete

        end

        def self.strings engines_id=nil, buckets_id=nil

            # get strings with bucket and module information
            strings = String
            .joins("inner join cloud_babel_buckets on cloud_babel_buckets.id = cloud_babel_strings.cloud_babel_buckets_id and cloud_babel_buckets.deleted_at is NULL")
            .joins("inner join cloud_babel_modules on cloud_babel_modules.id = cloud_babel_buckets.cloud_babel_modules_id and cloud_babel_modules.deleted_at is NULL")
            .where("cloud_babel_modules.id in (?)", TranslationsService.installed_engines_id)

            # filter by specific engines
            if engines_id
                strings = strings.where("cloud_babel_modules.id in (?)", engines_id)
            end

            # filter by specific engine buckets 
            if buckets_id
                strings = strings.where("cloud_babel_buckets.id in (?)", buckets_id)
            end

            strings

        end

        def self.strings_for_apps engines_id=nil, buckets_id=nil

            strings = strings(engines_id, buckets_id)
            strings = strings.select(
                :id, 
                :label,
                "cloud_babel_modules.name as engine_name",
                "cloud_babel_buckets.name as bucket_name",
                "cloud_babel_modules.platform",
                Rails.application.config.lesli_settings["configuration"]["locales"]
            )

            strings

        end

        def self.installed_engines_id

            # get the list of installed engines, including: rails_core, rails_builder, rails_engine
            babel_modules_names = Rails.application.config.lesli_settings["engines"].map { |engine| engine[:name] }

            # always include the core
            babel_modules_names.push("Core")

            # get list of ids of installed engines and available third-party apps
            CloudBabel::Module
            .where(:name => babel_modules_names) # -> only installed engines
            .or(CloudBabel::Module.where.not(:platform => ["rails_core", "rails_builder", "rails_engine"]))
            .map { |engine| engine.id } 
            
        end

    end
end

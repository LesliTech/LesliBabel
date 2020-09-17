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
            system "bundle exec rake i18n:js:export RAILS_ENV=production"
            return if Rails.env != "production"
            FileUtils.touch Rails.root.join("tmp", "restart.txt")
        end

        def self.clean

            # store full path to translation files for every language
            files_to_delete = []

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
            strings = Translation::String
            .joins("inner join cloud_babel_translation_buckets on cloud_babel_translation_buckets.id = cloud_babel_translation_strings.cloud_babel_translation_buckets_id")
            .joins("inner join cloud_babel_translation_modules on cloud_babel_translation_modules.id = cloud_babel_translation_buckets.cloud_babel_translation_modules_id")

            # filter by specific engines
            if engines_id
                strings = strings.where("cloud_babel_translation_modules.id in (?)", engines_id)
            end

            # filter by specific engine buckets 
            if buckets_id
                strings = strings.where("cloud_babel_translation_buckets.id in (?)", buckets_id)
            end

            strings = strings.select(
                :id,
                :label,
                :status,
                :context,
                :priority,
                :need_help,
                :need_translation,
                Rails.application.config.lesli_settings["configuration"]["locales"],
                "cloud_babel_translation_modules.id as engine_id",
                "cloud_babel_translation_buckets.id as bucket_id",
                "cloud_babel_translation_buckets.name as bucket_name",
                "cloud_babel_translation_modules.name as engine_name",
                "cloud_babel_translation_modules.module_type as module_type",
                "'' as path"
            )

        end

    end
end

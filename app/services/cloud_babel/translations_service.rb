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

            # delete all the translation files found

            files_to_delete.each do |file|
                FileUtils.rm_rf(file)
            end

            LC::Response.service true, files_to_delete

        end

        def self.prepare_strings_for_android_translations string
            puts "*     *     *     *     *     *     *     *     *     *     *     *     *"
            puts "*     *     *     *     *     *     *     *     *     *     *     *     *"
            puts "*     *     *     *     *     *     *     *     *     *     *     *     *"
            p string
            puts "*     *     *     *     *     *     *     *     *     *     *     *     *"
            puts "*     *     *     *     *     *     *     *     *     *     *     *     *"
            puts "*     *     *     *     *     *     *     *     *     *     *     *     *"
        end

        def self.prepare engines

            translations = { }

            strings = []

            strings = Translation::String
            .joins("inner join cloud_babel_translation_buckets on cloud_babel_translation_buckets.id = cloud_babel_translation_strings.cloud_babel_translation_buckets_id")
            .joins("inner join cloud_babel_translation_modules on cloud_babel_translation_modules.id = cloud_babel_translation_buckets.cloud_babel_translation_modules_id")

            if engines
                strings = strings.where("cloud_babel_translation_modules.name in (?)", engines)
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
                "cloud_babel_translation_buckets.id as cloud_babel_translation_buckets_id",
                "cloud_babel_translation_buckets.name as bucket_name",
                "cloud_babel_translation_modules.name as engine_name"
            )

            available_locales = Rails.application.config.lesli_settings["configuration"]["locales"]

            available_locales.each do |lang|
                translations[lang] = { }
            end

            return strings

            strings.each do |string|

                module_name = string.bucket.module.name.downcase.sub("cloud", "")
                module_type = string.bucket.module.module_type
                engine_name = string.bucket.module.name
                bucket_name = string.bucket.name

                available_locales.each do |lang|

                    # translations path for lesli core
                    file_path = Rails.root.join("config", "locales", bucket_name, "#{ bucket_name.gsub("/","_") }.#{ lang }.yml")

                    # translations path for Android & iOS apps
                    if module_type == "android" 
                        file_path = Rails.root.join("public", "locales", engine_name, "#{ bucket_name.gsub("/","_") }.#{ lang }.xml")
                    end

                    # translations path for translations for engines
                    if module_type == "rails_engine"
                        file_path = Rails.root.join("engines", engine_name, "config", "locales", bucket_name, "#{ bucket_name }.#{ lang }.yml")
                    end

                    file_id = file_path.to_s.to_sym

                    unless translations[lang].has_key? file_id
                        translations[lang][file_id] = { }
                    end

                    unless translations[lang][file_id].has_key? module_name
                        translations[lang][file_id][module_name] = { }
                    end

                    unless translations[lang][file_id][module_name].has_key? bucket_name
                        translations[lang][file_id][module_name][bucket_name] = { }
                    end

                    # send debug message for missing translations
                    string[lang] = ":" + string.path + ":" if string[lang].blank?

                    translations[lang][file_id][module_name][bucket_name][string.label] = string[lang]

                end

            end

            translations

        end

    end
end

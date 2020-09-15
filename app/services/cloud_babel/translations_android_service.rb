module CloudBabel
    class TranslationsAndroidService

        def self.build 

            translations = { }

            strings = []

            strings = Translation::String
            .joins("inner join cloud_babel_translation_buckets on cloud_babel_translation_buckets.id = cloud_babel_translation_strings.cloud_babel_translation_buckets_id")
            .joins("inner join cloud_babel_translation_modules on cloud_babel_translation_modules.id = cloud_babel_translation_buckets.cloud_babel_translation_modules_id")


                strings = strings.where("cloud_babel_translation_modules.name in (?)", "Android app")


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

            strings.each do |string|

                module_name = string.bucket.module.name.downcase.sub("cloud", "")
                module_type = string.bucket.module.module_type
                engine_name = string.bucket.module.name
                bucket_name = string.bucket.name

                available_locales.each do |lang|

                    file_path = Rails.root.join(
                        "public", 
                        "locales", 
                        engine_name, 
                        "values-#{lang}", 
                        "#{ bucket_name.gsub("/","_") }.xml"
                    )

                    file_id = file_path.to_s

                    unless translations.has_key? file_id
                        translations[file_id] = []
                    end

                    # send debug message for missing translations
                    string[lang] = ":" + string.path + ":" if string[lang].blank?

                    translations[file_id].push({
                        label: string.label, 
                        translation: string[lang]
                    })

                end

            end

            translations.each do |translation|

                file_path = translation[0]
                strings = translation[1]

                # creates folder and subfolders
                FileUtils.makedirs(File.dirname(file_path))

                # creates translation file for every available language
                translation_file = File.new(file_path, "w+")

                translation_file.write("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
                translation_file.write("<resources>\n")
                strings.each do |string|
                    p string
                    translation_file.write("<string name=\"#{string[:label]}\">#{string[:translation]}</string>\n")
                end
                translation_file.write("</resources>")

                translation_file.close

            end

        end

    end
end

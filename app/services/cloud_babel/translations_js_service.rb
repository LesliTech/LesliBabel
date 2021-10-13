module CloudBabel
    class TranslationsJsService

        def self.build

            # usually we download translations to use with other platforms like, flutter, reactnative, electron etc.
            # so for these cases we need to include all the translations 
            engines = Module.all.map do |engine|
                engine[:id]
            end

            # get strings filtered by module (only rails translations)
            strings = TranslationsService.strings(engines)

            strings = strings.select(
                :id,
                :label,
                :status,
                :context,
                :priority,
                :need_help,
                :need_translation,
                Rails.application.config.lesli_settings["configuration"]["locales"],
                "cloud_babel_modules.id as engine_id",
                "cloud_babel_buckets.id as bucket_id",
                "cloud_babel_buckets.name as bucket_name",
                "cloud_babel_modules.name as engine_name",
                "cloud_babel_modules.platform as platform",
                "'' as path"
            )

            translations = {}

            available_locales = Rails.application.config.lesli_settings["configuration"]["locales"]

            # add key for every available language (required by i18n Rails gem)
            available_locales.each do |lang|
                translations[lang] = { }
            end

            strings.each do |string|
                module_name = string[:engine_name].downcase.sub("cloud", "")
                engine_code = string[:engine_name].underscore
                engine_name = string[:engine_name]
                bucket_name = string[:bucket_name]
                platform = string[:platform]

                available_locales.each do |lang|

                    # translations path for lesli core
                    file_path = Rails.root.join("config", "locales", bucket_name, "#{ bucket_name.gsub("/","_") }.#{ lang }.js")

                    # translations path for translations for engines
                    file_path = Rails.root.join("public", "tmp", "locales", "#{lang}.json")

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
                    #string[lang] = ":" + string.path + ":" if string[lang].blank?

                    translations[lang][file_id][module_name][bucket_name][string.label] = string[lang]

                end

            end

            translation_files = []

            translations.each do |file_by_language|

                lang = file_by_language[0]
                file_by_controller = file_by_language[1]

                file_by_controller.each do |file|

                    file_path = file[0].to_s
                    translations = file[1]

                    translation_files.push(file_path)

                    # creates folder and subfolders
                    FileUtils.makedirs(File.dirname(file_path))

                    # creates translation file for every available language
                    translation_file = File.new(file_path, "w+")

                    translation_file.write({ "#{lang}": translations}.to_json)

                    translation_file.close

                    p "file added: #{ file_path }"

                end

            end

            LC::Response.service true, translation_files

        end

    end
end

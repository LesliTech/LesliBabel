module CloudBabel
    class TranslationsRailsService

        def self.build

            # get all rails engines
            engines = Translation::Module.where("module_type in ('rails_engine', 'rails_core')").map do |engine|
                engine[:id]
            end

            # get strings filtered by module (only rails translations)
            strings = TranslationsService.strings(engines)

            translations = {}

            available_locales = Rails.application.config.lesli_settings["configuration"]["locales"]

            # add key for every available language (required by i18n Rails gem)
            available_locales.each do |lang|
                translations[lang] = { }
            end

            strings.each do |string|

                module_name = string[:engine_name].downcase.sub("cloud", "")
                engine_name = string[:engine_name]
                module_type = string[:module_type]
                bucket_name = string[:bucket_name]

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

            translations.each do |file_by_language|

                lang = file_by_language[0]
                file_by_controller = file_by_language[1]

                file_by_controller.each do |file|

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

            LC::Response.service true, translations

        end

    end
end

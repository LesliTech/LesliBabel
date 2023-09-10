module LesliBabel
    class TranslationsMiddlemanService

        def self.build(engine_id)

            # get all rails engines
            engines = Module.where(:id => engine_id).map(&:id)
            
            # get strings filtered by module (only rails translations)
            strings = TranslationsService.strings_for_apps(engines)

            indexes = {}
            translations = {}
            available_locales = Rails.application.config.lesli_settings["configuration"]["locales"]

            # add key for every available language (required by i18n Rails gem)
            available_locales.each do |lang|
                translations[lang] = { :path => '', :labels => {} }
            end

            strings.each do |string|

                module_name = string[:engine_name].downcase.sub("cloud", "")
                engine_name = string[:engine_name]
                bucket_name = string[:bucket_name]
                module_type = string[:platform]
                
                bucket_name_clean = bucket_name.gsub("/","_")

                available_locales.each do |lang|

                    file_path = Rails.root.join(
                        "public", "tmp", "babel", "middleman","locales", "#{lang}.yml"
                    )

                    translations[lang][:file] = file_path.to_s

                    unless translations[lang][:labels].has_key? bucket_name
                        translations[lang][:labels][bucket_name] = { }
                    end

                    # send debug message for missing translations
                    string[lang] = ":" + string.path + ":" if string[lang].blank?

                    translations[lang][:labels][bucket_name][string.label] = string[lang]

                end

            end

            translation_files = []

            # Create translations files for every available language
            translations.each do |translation|

                lang = translation[0]
                file = translation[1][:file]
                labels = translation[1][:labels]
                
                translation_files.push(file)

                # creates folder and subfolders
                FileUtils.makedirs(File.dirname(file))

                # creates translation file for every available language
                translation_file = File.new(file, "w+")
                translation_file.write({ "#{lang.to_s}": labels}.to_yaml)
                translation_file.close

            end

            LC::Response.service true, translation_files

        end

    end
end

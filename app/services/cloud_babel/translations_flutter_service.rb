module CloudBabel
    class TranslationsFlutterService

        def self.build(engine_id = nil)

            # get all rails engines
            engines = Module.where(:id => engine_id).map do |engine|
                engine[:id]
            end

            # get strings filtered by module (only rails translations)
            strings = TranslationsService.strings_for_apps(engines)

            indexes = {}
            translations = {}
            available_locales = Rails.application.config.lesli_settings["configuration"]["locales"]

            strings.each do |string|

                module_name = string[:engine_name].downcase.sub("cloud", "")
                engine_name = string[:engine_name]
                bucket_name = string[:bucket_name]
                module_type = string[:platform]
                
                bucket_name_clean = bucket_name.gsub("/","_")

                available_locales.each do |lang|

                    file_path = Rails.root.join(
                        "public", "tmp", "babel", "flutter","l10n", "intl_#{lang}.arb"
                    )

                    file_id = file_path.to_s

                    unless translations.has_key? file_id
                        translations[file_id] = []
                    end

                    # send debug message for missing translations
                    string[lang] = ":" + string.path + ":" if string[lang].blank?

                    translations[file_id].push({
                        label: "#{bucket_name_clean}_#{string.label}".camelcase, 
                        translation: string[lang]
                    })

                end

                # Index keys
                if not indexes.has_key? bucket_name_clean
                    indexes[bucket_name_clean] = []
                end

                indexes[bucket_name_clean].push({
                    k: string.label.camelize(:lower),
                    v: "#{bucket_name_clean}_#{string.label}".upcase
                })

            end

            translation_files = []

            # Create translations files for every available language
            translations.each do |translation|

                file_path = translation[0]
                strings = translation[1]

                translation_files.push(file_path)

                # creates folder and subfolders
                FileUtils.makedirs(File.dirname(file_path))

                # creates translation file for every available language
                translation_file = File.new(file_path, "w+")

                translation_file.write("{\n")
                strings.each do |string|
                    translation_file.write("\"#{string[:label]}\": \"#{string[:translation]}\",\n")
                end
                translation_file.write("}\n")

                translation_file.close

            end

            LC::Response.service true, translation_files

        end

    end
end

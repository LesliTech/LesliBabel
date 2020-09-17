module CloudBabel
    class TranslationsIosService

        def self.build 

            # get all rails engines
            engines = Translation::Module.where(:module_type => "ios").map do |engine|
                engine[:id]
            end

            # get strings filtered by module (only rails translations)
            strings = TranslationsService.strings(engines)

            translations = {}

            available_locales = Rails.application.config.lesli_settings["configuration"]["locales"]

            strings.each do |string|

                module_name = string[:engine_name].downcase.sub("cloud", "")
                engine_name = string[:engine_name]
                module_type = string[:module_type]
                bucket_name = string[:bucket_name]

                available_locales.each do |lang|

                    file_path = Rails.root.join(
                        "public", "tmp", "locales", engine_name, "Resources",
                        "#{lang}.lproj", "Localizable.strings"
                    )

                    file_id = file_path.to_s

                    unless translations.has_key? file_id
                        translations[file_id] = []
                    end

                    # send debug message for missing translations
                    string[lang] = ":" + string.path + ":" if string[lang].blank?

                    translations[file_id].push({
                        label: "#{bucket_name.gsub("/","_")}_#{string.label}", 
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

                strings.each do |string|
                    translation_file.write("\"#{string[:label].upcase}\" = \"#{string[:translation]}\";\n")
                end

                translation_file.close

            end

            LC::Response.service true, translations

        end

    end
end

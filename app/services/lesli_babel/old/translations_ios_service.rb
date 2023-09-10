module LesliBabel
    class TranslationsIosService

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
                        label: "#{bucket_name_clean}_#{string.label}".upcase, 
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

                strings.each do |string|
                    translation_file.write("\"#{string[:label]}\" = \"#{string[:translation]}\";\n")
                end

                translation_file.close

            end

            # Create global label index file
            index_file_path = Rails.root.join("public", "tmp", "locales", "Translations.swift")

            FileUtils.makedirs(File.dirname(index_file_path))

            index_file = File.new(index_file_path, "w+")

            index_file.write("\ enum Translations { \n")

            indexes.each do |index_bucket|

                index_file.write("\ enum #{index_bucket[0]} { \n")

                index_bucket[1].each do |index_label|
                    index_file.write("static let #{index_label[:k]} = \"#{index_label[:v]}\"\n")
                end

                index_file.write("\ } \n")

            end

            index_file.write("\ } \n")

            index_file.close

            # include index into translation files zip
            translation_files.push(index_file_path)

            LC::Response.service true, translation_files

        end

    end
end

module CloudBabel
    class TranslationsRailsService

        def self.build

            engines = Translation::Module.where(:module_type => "rails_engine").map do |engine|
                engine[:name]
            end

            engines.push("Core")


            translations = TranslationsService.prepare(engines)


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

        end

    end
end

class TranslationsAndroidService
    
    def self.build
        files = { }

        available_locales = Rails.application.config.lesli_settings["configuration"]["locales"]

        available_locales.each do |lang|
            files[lang] = { }
        end

        Translation::String.all.each do |string|

            module_type = string.bucket.module.module_type
            module_name = string.bucket.module.name
            bucket_name = string.bucket.name

            # build translation files for rails applications only
            next unless ["rails_engine", "rails_core"].include? module_type

            module_name_sym = module_name.downcase.sub("cloud", "")

            available_locales.each do |lang|

                file_path = Rails.root.join("config", "locales", bucket_name, "#{ bucket_name.gsub("/","_") }.#{ lang }.yml")

                # prepend engine path when building translations for engines
                if module_type == "rails_engine"
                    file_path = Rails.root.join("engines", module_name, "config", "locales", bucket_name, "#{ bucket_name.gsub("/","_") }.#{ lang }.yml")
                end

                file_id = file_path.to_s.to_sym

                unless files[lang].has_key? file_id
                    files[lang][file_id] = { }
                end

                unless files[lang][file_id].has_key? module_name_sym
                    files[lang][file_id][module_name_sym] = { }
                end

                unless files[lang][file_id][module_name_sym].has_key? bucket_name
                    files[lang][file_id][module_name_sym][bucket_name] = { }
                end

                # send debug message for missing translations
                string[lang] = ":" + string.path + ":" if string[lang].blank?

                files[lang][file_id][module_name_sym][bucket_name][string.label] = string[lang]

            end

        end

        files.each do |file_by_language|

            lang = file_by_language[0]
            file_by_class = file_by_language[1]

            file_by_class.each do |file|

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

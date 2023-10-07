module LesliBabel
    class DeployRailsService < Lesli::ApplicationLesliService

        def build

            engines_installed = Lesli::System.engines.map do |name, engine|
                engine[:code]
            end

            # get all rails engines to buil
            engines = Module
                .where("platform in ('lesli_core', 'lesli_engine')")
                .where("code in (?)", engines_installed)
                .map do |engine|
                engine[:id]
            end

            # get strings filtered by module (only rails translations)
            strings = StringService.new(current_user, query).list(engines)

            strings = strings.select(
                :id,
                :label,
                :status,
                :context,
                Lesli.config.locales.keys,
                "lesli_babel_modules.id as engine_id",
                "lesli_babel_buckets.id as bucket_id",
                "lesli_babel_buckets.code as bucket_code",
                "lesli_babel_modules.code as engine_code",
                "lesli_babel_modules.platform as platform",
                "'' as path"
            )

            translations = {}

            available_locales = Lesli.config.locales.keys

            # add key for every available language (required by i18n Rails gem)
            available_locales.each do |lang|
                translations[lang] = { }
            end


            strings.each do |string|
                module_name = string[:engine_code]
                engine_code = string[:engine_code]
                engine_name = string[:engine_code]
                bucket_name = string[:bucket_code]
                platform = string[:platform]

                available_locales.each do |lang|

                    # translations path for lesli core
                    file_path = Rails.root.join(
                        "config", 
                        "locales", 
                        bucket_name, 
                        "#{ bucket_name.gsub("/","_") }.#{ lang }.yml"
                    )

                    # translations path for translations for engines
                    if platform == "rails_builder" || platform == "rails_engine" || platform == "standard"
                        file_path = Rails.root.join("engines", engine_name, "config", "locales", bucket_name, "#{ bucket_name }.#{ lang }.yml")
                        file_path = Rails.root.join("config", "locales", engine_code, bucket_name, "#{ bucket_name.gsub("/","_") }.#{ lang }.yml")
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

        end
    end
end

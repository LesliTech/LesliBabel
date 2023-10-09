module LesliBabel
    class DeployRailsService < Lesli::ApplicationLesliService

        def build

            Lesli::System.engines.each do |engine, engine_info|

                #next unless engine == "LesliAdmin"

                # get all rails engines to buil
                engine_id = Module
                .where("platform in ('lesli_core', 'lesli_engine')")
                .where(:code => engine_info[:code])
                .pluck(:id)

                # get strings filtered by module (only rails translations)
                strings = StringService.new(current_user, query).list(engine_id)

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

                available_locales.each do |lang|

                    # translations path for lesli core
                    file_path = "#{engine}::Engine".constantize.root.join(
                        "config", "locales", "translations.#{lang}.yml"
                    )

                    file_id = file_path.to_s.to_sym

                    strings.each do |string|
                        bucket_name = string[:bucket_code]

                        unless translations[lang].has_key? file_id
                            translations[lang][file_id] = { }
                        end

                        unless translations[lang][file_id].has_key? bucket_name
                            translations[lang][file_id][bucket_name] = { }
                        end

                        # send debug message for missing translations
                        string[lang] = ":" + string.path + ":" if string[lang].blank?

                        translations[lang][file_id][bucket_name][string.label] = string[lang]

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
end

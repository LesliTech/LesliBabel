module LesliBabel
    class DeployRailsService < Lesli::ApplicationLesliService

        def build

            Lesli::System.engines.each do |engine, engine_info|

                # get all rails engines to buil
                engine_id = Module
                .where("platform in ('lesli_core', 'lesli_engine')")
                .where(:code => engine_info[:code])
                .pluck(:id)

                engine_id_lesli = Module
                .where("platform in ('lesli_core', 'lesli_engine')")
                .where(:code => "lesli")
                .pluck(:id)

                bucket_id_shared = Bucket
                .where(:code => "shared")
                .where(:module_id => engine_id_lesli)
                .pluck(:id)

                bucket_id_application = Bucket
                .where(:code => "application")
                .where(:module_id => engine_id_lesli)
                .pluck(:id)

                # get strings filtered by module (only rails translations)
                strings = StringService.new(current_user, query).list(engine_id)
                strings_shared = StringService.new(current_user, query).list(engine_id_lesli, bucket_id_shared)
                strings_application = StringService.new(current_user, query).list(engine_id_lesli, bucket_id_application)

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
                    translations[lang] = { 
                        :file => "",
                        :labels => {}
                    }
                end

                engine_code = engine_info[:code]

                available_locales.each do |lang|

                    # translations path for lesli core
                    translations[lang][:file] = "#{engine}::Engine".constantize.root.join(
                        "config", "locales", "translations.#{lang}.yml"
                    ).to_s

                    # Create a collection of strings for the current module
                    strings.each do |string|
                        
                        bucket_code = string[:bucket_code]

                        unless translations[lang][:labels].has_key? engine_code
                            translations[lang][:labels][engine_code] = { }
                        end

                        unless translations[lang][:labels][engine_code].has_key? bucket_code
                            translations[lang][:labels][engine_code][bucket_code] = { }
                        end

                        # # send debug message for missing translations
                        string[lang] = ":" + string.path + ":" if string[lang].blank?

                        translations[lang][:labels][engine_code][bucket_code][string.label] = string[lang]

                    end

                    # Create a collection of strings for the shared labels of Lesli
                    strings_shared.each do |string|

                        unless translations[lang][:labels].has_key? "lesli"
                            translations[lang][:labels]["lesli"] = { }
                        end

                        unless translations[lang][:labels]["lesli"].has_key? "shared"
                            translations[lang][:labels]["lesli"]["shared"] = { }
                        end

                        # # send debug message for missing translations
                        string[lang] = ":" + string.path + ":" if string[lang].blank?

                        translations[lang][:labels]["lesli"]["shared"][string.label] = string[lang]
                    end

                    # Create a collection of strings for the application labels of Lesli
                    strings_application.each do |string|

                        unless translations[lang][:labels].has_key? "lesli"
                            translations[lang][:labels]["lesli"] = { }
                        end

                        unless translations[lang][:labels]["lesli"].has_key? "application"
                            translations[lang][:labels]["lesli"]["application"] = { }
                        end

                        # # send debug message for missing translations
                        string[lang] = ":" + string.path + ":" if string[lang].blank?

                        translations[lang][:labels]["lesli"]["application"][string.label] = string[lang]
                    end

                end

                translations.each do |lang, translations|

                    # creates folder and subfolders
                    FileUtils.makedirs(File.dirname(translations[:file]))

                    # creates translation file for every available language
                    translation_file = File.new(translations[:file], "w+")

                    translation_file.write({ "#{lang}": translations[:labels] }.to_yaml)

                    translation_file.close

                    #L2.msg "file added: #{ translations[:file] }"
                end
            end
        end
    end
end

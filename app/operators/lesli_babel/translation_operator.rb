module LesliBabel
    class TranslationOperator < Lesli::ApplicationLesliService

        def deploy

            Lesli::System.engines.each do |engine, engine_info|

                next if engine == "Root"

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

                # get labels filtered by module (only rails translations)
                labels = LabelService.new(current_user, query).builder(modules_id:engine_id).order(created_at: :asc)
                labels_shared = LabelService.new(current_user, query).builder(modules_id:engine_id_lesli, buckets_id:bucket_id_shared).order(created_at: :asc)
                labels_application = LabelService.new(current_user, query).builder(modules_id:engine_id_lesli, buckets_id:bucket_id_application).order(created_at: :asc)

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

                    # Create a collection of labels for the current module
                    labels.each do |label|
                        
                        bucket_code = label[:bucket_code]

                        unless translations[lang][:labels].has_key? engine_code
                            translations[lang][:labels][engine_code] = { }
                        end

                        unless translations[lang][:labels][engine_code].has_key? bucket_code
                            translations[lang][:labels][engine_code][bucket_code] = { }
                        end

                        # # send debug message for missing translations
                        label[lang] = ":" + label.path + ":" if label[lang].blank?

                        translations[lang][:labels][engine_code][bucket_code][label.text] = label[lang]

                    end

                    # Create a collection of labels for the shared labels of Lesli
                    labels_shared.each do |label|

                        unless translations[lang][:labels].has_key? "lesli"
                            translations[lang][:labels]["lesli"] = { }
                        end

                        unless translations[lang][:labels]["lesli"].has_key? "shared"
                            translations[lang][:labels]["lesli"]["shared"] = { }
                        end

                        # # send debug message for missing translations
                        label[lang] = ":" + label.path + ":" if label[lang].blank?

                        translations[lang][:labels]["lesli"]["shared"][label.text] = label[lang]
                    end

                    # Create a collection of labels for the application labels of Lesli
                    labels_application.each do |label|

                        unless translations[lang][:labels].has_key? "lesli"
                            translations[lang][:labels]["lesli"] = { }
                        end

                        unless translations[lang][:labels]["lesli"].has_key? "application"
                            translations[lang][:labels]["lesli"]["application"] = { }
                        end

                        # # send debug message for missing translations
                        label[lang] = ":" + label.path + ":" if label[lang].blank?

                        translations[lang][:labels]["lesli"]["application"][label.text] = label[lang]
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

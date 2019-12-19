
namespace :cloud_babel do

    desc "Create standard structure for translations according to the objects in the app"
    task scan: [:environment] do  

        load_demo_data = true

        controllers = Rails.application.routes.routes.map do |route|
            route.defaults[:controller]
        end.uniq

        controllers.each do |controller|
            next if controller.blank?
            next if controller.include? "rails"
            next if controller.include? "action_mailbox"
            next if controller.include? "active_storage"
            next if controller.include? "users"
            next if controller.include? "account"

            # Add object to the translation workflow
            translation = CloudBabel::Translation.find_or_create_by({ module_name: 'core', class_name: controller })

            scan_models translation, load_demo_data

            scan_controllers translation, load_demo_data 

            scan_views translation, load_demo_data 

            p "object found: #{controller}"

        end

    end


    desc "Build translation files"
    task build: :environment do

        files = { }

        available_langs = ['en', 'es', 'de']

        available_langs.each do |lang|
            files[lang] = { file_path: "", translations: {} }
            files[lang] = { }
        end

        CloudBabel::TranslationObjectGroupLabel.all.each do |label|

            available_langs.each do |lang|

                module_name = label.group.object.translation.module_name

                class_name = label.group.object.translation.class_name

                object_type = label.group.object.object_type

                method = label.group.method

                section = label.group.section

                file_path = Rails.root.join("config", "locales", object_type, class_name, "#{class_name.gsub('/','_')}.#{lang}.yml")

                file_id = file_path.to_s.to_sym

                files[lang][file_id] = { }

                unless files[lang][file_id].has_key? module_name
                    files[lang][file_id][module_name] = { }
                end

                unless files[lang][file_id][module_name].has_key? class_name
                    files[lang][file_id][module_name][class_name] = { }
                end

                unless files[lang][file_id][module_name][class_name].has_key? object_type
                    files[lang][file_id][module_name][class_name][object_type] = { }
                end

                unless files[lang][file_id][module_name][class_name][object_type].has_key? method
                    files[lang][file_id][module_name][class_name][object_type][method] = { }
                end

                unless files[lang][file_id][module_name][class_name][object_type][method].has_key? section
                    files[lang][file_id][module_name][class_name][object_type][method][section] = { }
                end

                files[lang][file_id][module_name][class_name][object_type][method][section][label.label] = label[lang]

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
    


    def scan_models translation, load_demo_data

        # Model object for current translation
        translation_object = CloudBabel::TranslationObject.find_or_create_by({
            object_type: 'models',
            translation: translation
        })

        # Model actions and sections
        ['create', 'update', 'destroy'].each do |method|

            ['messages'].each do |section|

                translation_object_group = CloudBabel::TranslationObjectGroup.find_or_create_by({
                    method: method,
                    section: section,
                    object: translation_object
                })

                if load_demo_data
                    CloudBabel::TranslationObjectGroupLabel.find_or_create_by({
                        label: "label_demo",
                        es: "Etiqueta de demo",
                        en: "Label demo",
                        de: "Label demo",
                        fr: "",
                        group: translation_object_group
                    })
                end

            end

        end

    end

    def scan_controllers translation, load_demo_data

        # Controller object for current translation
        translation_object = CloudBabel::TranslationObject.find_or_create_by({
            object_type: 'controllers',
            translation: translation
        })

        # Controller actions and sections
        ['index', 'show', 'new', 'edit', 'create', 'update', 'destroy'].each do |method|

            ['actions', 'messages'].each do |section|

                translation_object_group = CloudBabel::TranslationObjectGroup.find_or_create_by({
                    method: method,
                    section: section,
                    object: translation_object
                })

                if load_demo_data
                    CloudBabel::TranslationObjectGroupLabel.find_or_create_by({
                        label: "label_demo",
                        es: "Etiqueta de demo",
                        en: "Label demo",
                        de: "Label demo",
                        fr: "",
                        group: translation_object_group
                    })
                end

            end

        end

    end

    def scan_views translation, load_demo_data

        # View object for current translation
        translation_object = CloudBabel::TranslationObject.find_or_create_by({
            object_type: 'views',
            translation: translation
        })

        # View actions and sections
        ['index', 'show', 'new', 'edit', 'delete'].each do |method|

            ['messages'].each do |section|

                translation_object_group = CloudBabel::TranslationObjectGroup.find_or_create_by({
                    method: method,
                    section: section,
                    object: translation_object
                })

                if load_demo_data
                    CloudBabel::TranslationObjectGroupLabel.find_or_create_by({
                        label: "label_demo",
                        es: "Etiqueta de demo",
                        en: "Label demo",
                        de: "Label demo",
                        fr: "",
                        group: translation_object_group
                    })
                end

            end

        end

    end

end

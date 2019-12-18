
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

            # Add object to the translation workflow
            translation = CloudBabel::Translation.find_or_create_by({ module_name: 'core', class_name: controller })

            #scan_models translation, load_demo_data

            #scan_controllers translation, load_demo_data 

            scan_views translation, load_demo_data 

            p "object found: #{controller}"

        end

    end

    desc ""
    task build: :environment do

        temp = { }

        available_langs = ['en', 'es', 'de']

        available_langs.each do |lang|
            temp[lang] = { file_path: "", translations: {} }
        end

        CloudBabel::TranslationObjectGroupLabel.all.each do |label|

            available_langs.each do |lang|

                module_name = label.group.object.translation.module_name

                unless temp[lang][:translations].has_key? module_name
                    temp[lang][:translations][module_name] = { }
                end

                class_name = label.group.object.translation.class_name

                unless temp[lang][:translations][module_name].has_key? class_name
                    temp[lang][:translations][module_name][class_name] = { }
                end

                object_type = label.group.object.object_type

                unless temp[lang][:translations][module_name][class_name].has_key? object_type
                    temp[lang][:translations][module_name][class_name][object_type] = { }
                end

                method = label.group.method

                unless temp[lang][:translations][module_name][class_name][object_type].has_key? method
                    temp[lang][:translations][module_name][class_name][object_type][method] = { }
                end

                section = label.group.section

                unless temp[lang][:translations][module_name][class_name][object_type][method].has_key? section
                    temp[lang][:translations][module_name][class_name][object_type][method][section] = { }
                end

                temp[lang][:translations][module_name][class_name][object_type][method][section][label.label] = label[lang]


                temp[lang][:file_path] = Rails.root.join("config", "locales", object_type, class_name, "#{class_name}.#{lang}.yml")

            end

        end

        temp.each do |translation|

            lang = translation[0]
            translation = translation[1]

            # creates folder and subfolders
            FileUtils.makedirs(File.dirname(translation[:file_path]))

            # creates translation file for every available language
            translation_file = File.new(translation[:file_path], "w+")

            translation_file.write({ "#{lang}": translation[:translations]}.to_yaml)

            translation_file.close

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

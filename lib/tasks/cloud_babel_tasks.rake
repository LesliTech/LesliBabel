
namespace :cloud_babel do

    desc "Create standard structure for translations according to the objects in the app"
    task scan: [:environment] do  

        load_demo_data = false

        translation_list = []

        # build core controller list
        translation_list = get_controllers_from_routes(translation_list, Rails.application.routes.routes, "Core")

        # build engines controller list
        translation_list = get_controllers_from_routes(translation_list, CloudTeam::Engine.routes.routes, CloudTeam) if defined?(CloudTeam)
        translation_list = get_controllers_from_routes(translation_list, CloudDriver::Engine.routes.routes, CloudDriver) if defined?(CloudDriver)
        translation_list = get_controllers_from_routes(translation_list, CloudLesli::Engine.routes.routes, CloudLesli) if defined?(CloudLesli)
        translation_list = get_controllers_from_routes(translation_list, CloudBell::Engine.routes.routes, CloudBell) if defined?(CloudBell)
        translation_list = get_controllers_from_routes(translation_list, CloudKb::Engine.routes.routes, CloudKb) if defined?(CloudKb)
        translation_list = get_controllers_from_routes(translation_list, CloudHelp::Engine.routes.routes, CloudHelp) if defined?(CloudHelp)
        translation_list = get_controllers_from_routes(translation_list, CloudPanel::Engine.routes.routes, CloudPanel) if defined?(CloudPanel)
        translation_list = get_controllers_from_routes(translation_list, CloudLock::Engine.routes.routes, CloudLock) if defined?(CloudLock)
        translation_list = get_controllers_from_routes(translation_list, CloudBabel::Engine.routes.routes, CloudBabel) if defined?(CloudBabel)

        translation_list.each do |t|
            
            # Add object to the translation workflow
            translation = CloudBabel::Translation.find_or_create_by({ module_name: t[:module_name], class_name: t[:class_name] })

            build_standard_labels_for translation, 'views', ['index', 'show', 'new', 'edit', 'delete'], load_demo_data
            build_standard_labels_for translation, 'models', ['create', 'update', 'destroy'], load_demo_data
            build_standard_labels_for translation, 'controllers', ['index', 'show', 'new', 'edit', 'create', 'update', 'destroy'], load_demo_data
            
            p "object found: #{t[:module_name]}/#{t[:class_name]}"

        end

    end

    def get_controllers_from_routes controller_list, routes, engine

        routes.map do |route|
            route.defaults[:controller]
        end.uniq.each do |controller|
            next if controller.blank?
            next if controller.include? "rails"
            next if controller.include? "action_mailbox"
            next if controller.include? "active_storage"

            engine = engine.to_s
            engine_sym_name = engine.downcase.sub('cloud', 'cloud_')
            controller = controller.sub(engine_sym_name + '/', '')

            controller_list.push({ module_name: engine, class_name: controller })
        end

        # shared engine translations 
        controller_list.push({ module_name: engine, class_name: 'shared' })

        return controller_list

    end

    def build_standard_labels_for translation, object_type, actions, load_demo_data

        # Model object for current translation
        translation_object = CloudBabel::TranslationObject.find_or_create_by({
            object_type: object_type,
            translation: translation
        })

        actions.each do |method|

            translation_object_group = CloudBabel::TranslationObjectGroup.find_or_create_by({
                method: method,
                object: translation_object
            })

            ['alerts', 'messages'].each do |section|

                translation_object_group_section = CloudBabel::TranslationObjectGroupSection.find_or_create_by({
                    name: section,
                    group: translation_object_group
                })

                if load_demo_data
                    CloudBabel::TranslationObjectGroupSectionLabel.find_or_create_by({
                        label: "label_demo",
                        es: "Etiqueta de demo",
                        en: "Label demo",
                        de: "Label demo",
                        fr: "",
                        users_id: 1,
                        section: translation_object_group_section
                    })
                end

            end

        end

    end


    desc "Build translation files"
    task build: :environment do

        files = { }

        available_langs = ['en', 'es', 'de']

        available_langs.each do |lang|
            files[lang] = { }
        end

        CloudBabel::TranslationObjectGroupSectionLabel.all.each do |label|

            available_langs.each do |lang|

                module_name = label.section.group.object.translation.module_name

                module_name_sym = module_name.downcase.sub('cloud', 'cloud_')
                module_name_sym = module_name.downcase.sub('cloud', '')

                class_name = label.section.group.object.translation.class_name

                object_type = label.section.group.object.object_type

                method = label.section.group.method

                section = label.section.name

                file_path = Rails.root.join("config", "locales", object_type, class_name, "#{class_name.gsub('/','_')}.#{lang}.yml")

                if module_name != "Core"
                    file_path = Rails.root.join("engines", module_name, "config", "locales", object_type, class_name, "#{class_name.gsub('/','_')}.#{lang}.yml")
                end

                file_id = file_path.to_s.to_sym

                unless files[lang].has_key? file_id
                    files[lang][file_id] = { }
                end

                unless files[lang][file_id].has_key? module_name_sym
                    files[lang][file_id][module_name_sym] = { }
                end

                unless files[lang][file_id][module_name_sym].has_key? class_name
                    files[lang][file_id][module_name_sym][class_name] = { }
                end

                unless files[lang][file_id][module_name_sym][class_name].has_key? object_type
                    files[lang][file_id][module_name_sym][class_name][object_type] = { }
                end

                unless files[lang][file_id][module_name_sym][class_name][object_type].has_key? method
                    files[lang][file_id][module_name_sym][class_name][object_type][method] = { }
                end

                unless files[lang][file_id][module_name_sym][class_name][object_type][method].has_key? section
                    files[lang][file_id][module_name_sym][class_name][object_type][method][section] = { }
                end

                files[lang][file_id][module_name_sym][class_name][object_type][method][section][label.label] = label[lang]

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

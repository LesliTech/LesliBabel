
namespace :cloud_babel do

    desc "Create standard structure for translations according to the objects in the app"
    task scan: [:environment] do  

        load_demo_data = true

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

            p "object found: #{t[:module_name]}/#{t[:object_name]}"

            # Add object to the translation workflow
            translation_module = CloudBabel::Translation::Module.find_or_create_by({ name: t[:module_name] })
            translation_object = CloudBabel::Translation::Object.find_or_create_by({ name: t[:object_name], object_type: 'object', module: translation_module })

            # Shared strings should not have this tree
            if t[:object_name] == "shared"
                register_shared_labels_for translation_object, load_demo_data
            else
                register_standard_labels_for translation_object, 'views', ['index', 'show', 'new', 'edit', 'delete'], load_demo_data
                register_standard_labels_for translation_object, 'models', ['create', 'update', 'destroy'], load_demo_data
                register_standard_labels_for translation_object, 'controllers', ['index', 'show', 'new', 'edit', 'create', 'update', 'destroy'], load_demo_data
            end

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

            controller_list.push({ module_name: engine, object_name: controller })
        end

        # shared engine translations 
        controller_list.push({ module_name: engine, object_name: 'shared' })

        return controller_list

    end

    def register_shared_labels_for translation, load_demo_data

        if load_demo_data
            user = ::User.find(1)
            CloudBabel::Translation::String.find_or_create_by({
                label: "shared_label_demo",
                es: "Etiqueta de demo",
                en: "Label demo",
                de: "Label demo",
                fr: "",
                object: translation
            })
        end

    end

    def register_standard_labels_for translation, object_type, actions, load_demo_data

        # Model object for current translation (module)
        translation_object = CloudBabel::Translation::Object.find_or_create_by({
            name: object_type,
            object_type: 'object_type',
            parent: translation
        })

        actions.each do |action_name|

            translation_object_action = CloudBabel::Translation::Object.find_or_create_by({
                name: action_name,
                object_type: 'action',
                parent: translation_object
            })

            ['alerts', 'messages'].each do |section_name|

                translation_object_action_section = CloudBabel::Translation::Object.find_or_create_by({
                    name: section_name,
                    object_type: 'section',
                    parent: translation_object_action
                })

                if load_demo_data
                    CloudBabel::Translation::String.find_or_create_by({
                        label: "label_demo",
                        es: "Etiqueta de demo",
                        en: "Label demo",
                        de: "Label demo",
                        fr: "",
                        object: translation_object_action_section
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

        CloudBabel::Translation::String.where(status: 1).each do |string|

            if string.object.name == "shared"

                object = string.object
                module_name = object.module.name

                module_name_sym = module_name.downcase.sub('cloud', '')

                available_langs.each do |lang|

                    file_path = Rails.root.join("config", "locales", object.name, "#{object.name.gsub('/','_')}.#{lang}.yml")

                    if module_name != "Core"
                        file_path = Rails.root.join("engines", module_name, "config", "locales", object.name, "#{object.name.gsub('/','_')}.#{lang}.yml")
                    end

                    file_id = file_path.to_s.to_sym

                    unless files[lang].has_key? file_id
                        files[lang][file_id] = { }
                    end

                    unless files[lang][file_id].has_key? module_name_sym
                        files[lang][file_id][module_name_sym] = { }
                    end

                    unless files[lang][file_id][module_name_sym].has_key? object.name
                        files[lang][file_id][module_name_sym][object.name] = { }
                    end

                    files[lang][file_id][module_name_sym][object.name][string.label] = string[lang]

                end

            else

                section = string.object
                action = section.parent
                type = action.parent
                object = type.parent
                module_name = object.module.name

                module_name_sym = module_name.downcase.sub('cloud', '')

                available_langs.each do |lang|

                    file_path = Rails.root.join("config", "locales", type.name, object.name, "#{object.name.gsub('/','_')}.#{lang}.yml")

                    if module_name != "Core"
                        file_path = Rails.root.join("engines", module_name, "config", "locales", type.name, object.name, "#{object.name.gsub('/','_')}.#{lang}.yml")
                    end

                    file_id = file_path.to_s.to_sym

                    unless files[lang].has_key? file_id
                        files[lang][file_id] = { }
                    end

                    unless files[lang][file_id].has_key? module_name_sym
                        files[lang][file_id][module_name_sym] = { }
                    end

                    unless files[lang][file_id][module_name_sym].has_key? object.name
                        files[lang][file_id][module_name_sym][object.name] = { }
                    end

                    unless files[lang][file_id][module_name_sym][object.name].has_key? type.name
                        files[lang][file_id][module_name_sym][object.name][type.name] = { }
                    end

                    unless files[lang][file_id][module_name_sym][object.name][type.name].has_key? action.name
                        files[lang][file_id][module_name_sym][object.name][type.name][action.name] = { }
                    end

                    unless files[lang][file_id][module_name_sym][object.name][type.name][action.name].has_key? section.name
                        files[lang][file_id][module_name_sym][object.name][type.name][action.name][section.name] = { }
                    end

                    files[lang][file_id][module_name_sym][object.name][type.name][action.name][section.name][string.label] = string[lang]

                end

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

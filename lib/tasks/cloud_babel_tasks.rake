
namespace :cloud_babel do

    desc "Create standard structure for translations according to the objects in the app"
    task scan: [:environment] do  

        load_demo_data = false

        translation_list = []

        # build core controller list
        translation_list = get_controllers_from_routes(translation_list, Rails.application.routes.routes, "Core")

        # build engines controller list
        translation_list = get_controllers_from_routes(translation_list, CloudTeam::Engine.routes.routes, CloudTeam) if defined?(CloudTeam)
        #controllers_happy = get_controllers_from_routes(CloudHappy::Engine.routes.routes, CloudHappy) if defined?(CloudHappy)
        #controllers_seller = get_controllers_from_routes(CloudSeller::Engine.routes.routes, CloudSeller) if defined?(CloudSeller)
        #controllers_leaf = get_controllers_from_routes(CloudLeaf::Engine.routes.routes, CloudLeaf) if defined?(CloudLeaf)
        #controllers_drop = get_controllers_from_routes(CloudDrop::Engine.routes.routes, CloudDrop) if defined?(CloudDrop)
        #controllers_mailer = get_controllers_from_routes(CloudMailer::Engine.routes.routes, CloudMailer) if defined?(CloudMailer)
        translation_list = get_controllers_from_routes(translation_list, CloudDriver::Engine.routes.routes, CloudDriver) if defined?(CloudDriver)
        #controllers_chaos = get_controllers_from_routes(CloudChaos::Engine.routes.routes, CloudChaos) if defined?(CloudChaos)
        #controllers_clock = get_controllers_from_routes(CloudClock::Engine.routes.routes, CloudClock) if defined?(CloudClock)
        #controllers_pizza = get_controllers_from_routes(CloudPizza::Engine.routes.routes, CloudPizza) if defined?(CloudPizza)
        #controllers_notes = get_controllers_from_routes(CloudNotes::Engine.routes.routes, CloudNotes) if defined?(CloudNotes)
        translation_list = get_controllers_from_routes(translation_list, CloudLesli::Engine.routes.routes, CloudLesli) if defined?(CloudLesli)
        #controllers_social = get_controllers_from_routes(CloudSocial::Engine.routes.routes, CloudSocial) if defined?(CloudSocial)
        translation_list = get_controllers_from_routes(translation_list, CloudBell::Engine.routes.routes, CloudBell) if defined?(CloudBell)
        #controllers_books = get_controllers_from_routes(CloudBooks::Engine.routes.routes, CloudBooks) if defined?(CloudBooks)
        #controllers_wallet = get_controllers_from_routes(CloudWallet::Engine.routes.routes, CloudWallet) if defined?(CloudWallet)
        #controllers_things = get_controllers_from_routes(CloudThings::Engine.routes.routes, CloudThings) if defined?(CloudThings)
        translation_list = get_controllers_from_routes(translation_list, CloudKb::Engine.routes.routes, CloudKb) if defined?(CloudKb)
        translation_list = get_controllers_from_routes(translation_list, CloudHelp::Engine.routes.routes, CloudHelp) if defined?(CloudHelp)
        #controllers_portal = get_controllers_from_routes(CloudPortal::Engine.routes.routes, CloudPortal) if defined?(CloudPortal)
        #controllers_bug = get_controllers_from_routes(CloudBug::Engine.routes.routes, CloudBug) if defined?(CloudBug)
        translation_list = get_controllers_from_routes(translation_list, CloudPanel::Engine.routes.routes, CloudPanel) if defined?(CloudPanel)
        translation_list = get_controllers_from_routes(translation_list, CloudLock::Engine.routes.routes, CloudLock) if defined?(CloudLock)
        translation_list = get_controllers_from_routes(translation_list, CloudBabel::Engine.routes.routes, CloudBabel) if defined?(CloudBabel)

        translation_list.each do |t|
            
            # Add object to the translation workflow
            translation = CloudBabel::Translation.find_or_create_by({ module_name: t[:module_name], class_name: t[:class_name] })

            scan_models translation, load_demo_data

            scan_controllers translation, load_demo_data 

            scan_views translation, load_demo_data 

            p "object found: #{t[:module_name]}/#{t[:class_name]}"

        end

    end


    desc "Build translation files"
    task build: :environment do

        files = { }

        available_langs = ['en', 'es', 'de']

        available_langs.each do |lang|
            files[lang] = { }
        end

        CloudBabel::TranslationObjectGroupLabel.all.each do |label|

            available_langs.each do |lang|

                module_name = label.group.object.translation.module_name

                module_name_sym = module_name.downcase.sub('cloud', 'cloud_')
                module_name_sym = module_name.downcase.sub('cloud', '')

                class_name = label.group.object.translation.class_name

                object_type = label.group.object.object_type

                method = label.group.method

                section = label.group.section

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
        return controller_list
    end

end

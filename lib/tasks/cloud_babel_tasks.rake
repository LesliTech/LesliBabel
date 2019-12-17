# desc "Explaining what the task does"
namespace :cloud_babel do
    task scan: :environment do

        controllers = Rails.application.routes.routes.map do |route|
            route.defaults[:controller]
        end.uniq

        controllers.each do |controller|
            next if controller.blank?
            next if controller.include? "rails"
            next if controller.include? "action_mailbox"
            next if controller.include? "active_storage"
            next unless controller.include? "websites" 
            
            translation = CloudBabel::Translation.create({ module_name: 'core', class_name: controller })

            # Model object for current translation
            translation_object = CloudBabel::TranslationObject.create({
                object_type: 'views',
                translation: translation
            })


            # Model groups and sections
            ['create', 'update', 'destroy'].each do |method|

                ['actions', 'messages'].each do |section|

                    translation_object_group = CloudBabel::TranslationObjectGroup.create({
                        method: method,
                        section: section,
                        object: translation_object
                    })

                    CloudBabel::TranslationObjectGroupLabel.create({
                        label: "label_demo_for_#{section}",
                        es: "Etiqueta de demo para #{section}",
                        en: "Label demo for #{section}",
                        de: "Label Demo für #{section}",
                        fr: "",
                        group: translation_object_group
                    })

                end

            end

        end        

    end

    task build2: :environment do

        temp = { }

        available_langs = ['en', 'es', 'de']

        available_langs.each do |lang|
            temp[lang] = { file_path: "", translations: {} }
        end


        CloudBabel::TranslationObjectGroupLabel.all.each do |label|
            #p label.label
            #p label.group.object.translation.class_name
            #p label.group.object.translation.module_name

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

    task build: :environment do

        CloudBabel::Translation.all.each do |translation|

            translation.translation_objects.each do |translation_object|

                path_directory = Rails.root.join("config", "locales", translation_object.object_type, translation.class_name)

                translation_by_lang = { }

                available_langs = ['en']

                available_langs.each do |lang|

                    translation_by_lang[lang.to_sym] = {
                        file_path: path_directory.join("#{translation.class_name}.#{lang}.yml"),
                        translations: { 
                            "#{lang}": {
                                core: {
                                    "#{translation.class_name}": { }
                                }
                            }
                        }
                    }

                end
                
                translation_object.translation_object_groups.each do |translation_object_group|

                    translation_object_group.translation_object_group_labels.each do |translation_object_group_label|

                        available_langs.each do |lang|


                        end

                    end

                end

                p translation_by_lang

                translation_by_lang.each do |translation|

                    translation = translation[1]

                    # creates folder and subfolders
                    FileUtils.makedirs(File.dirname(translation[:file_path]))

                    # creates translation file for every available language
                    translation_file = File.new(translation[:file_path], "w+")

                    translation_file.write(translation[:translations].to_yaml)

                    translation_file.close

                end

            end

        end

    end
    
end

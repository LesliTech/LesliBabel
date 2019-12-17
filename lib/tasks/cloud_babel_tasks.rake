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
            
            translation = CloudBabel::Translation.create({ module_name: 'Core', class_name: controller })

            # controller objects
            ['index', 'show', 'new', 'edit', 'create', 'update', 'destroy'].each do |method|
                translation_object = CloudBabel::TranslationObject.create({
                    object_type: 'controllers',
                    method: method,
                    section: 'messages',
                    translation: translation
                })

                ['label_1', 'label_2'].each_with_index do |label,index|
                    CloudBabel::TranslationObjectString.create({
                        label: label,
                        es: 'Etiqueta ' + (index+1).to_s,
                        en: 'Label ' + (index+1).to_s,
                        de: 'Etikette ' + (index+1).to_s,
                        fr: '',
                        translation_object: translation_object
                    })
                end

            end

        end        

    end


    task build: :environment do
        CloudBabel::Translation.all.each do |translation|

            translation.translation_objects.each do |translation_object|

                path_directory = Rails.root.join("config", "locales", translation_object.object_type, translation.class_name)

                translations_en = {
                    en: {
                        core: {
                            websites: {
                                new: {
                                    new_user: 'Crear nuevo usuario',
                                    create: 'Crear'
                                }
                            }
                        }
                    }
                }

                translation_strings_by_lang = {}

                translation_object.translation_object_strings.each do |translation_object_string|

                    ['en','es','de'].each do |lang|
                        translation_strings_by_lang[lang] = {
                            "#{lang}": {
                                core: {
                                    "#{translation.class_name}": {
                                        "#{translation_object.method}": {
                                            "#{translation_object.section}": {
                                                "#{translation_object_string.label}": translation_object_string[lang]
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    end

                end

                translation_strings_by_lang.each do |strings_by_lang|
                    lang = strings_by_lang[0]
                    strings = strings_by_lang[1]
                    path_file = path_directory.join("#{translation.class_name}.#{lang}.yml")
                    FileUtils.makedirs(path_directory)
                    translation_file = File.new(path_file, "w+")
                    translation_file.write(strings.to_yaml)
                    translation_file.close
                    p path_file.to_s
                end

            end
        end
    end
end

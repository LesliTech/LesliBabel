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
                        de: '',
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
                directory = Rails.root.join("config", "locales", translation_object.object_type, translation.class_name)
                FileUtils.makedirs(directory)
                translation_file = File.new(directory.join(translation.class_name+".yml"), "w+")
                translation_file.close
            end
        end
    end
end

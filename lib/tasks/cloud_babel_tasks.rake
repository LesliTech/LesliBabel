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
            
            translation = CloudBabel::Translation.create({ module_name: 'Core', class_name: controller })

            # controller objects
            ['index', 'show', 'new', 'edit', 'create', 'update', 'destroy'].each do |method|
                translation_object = CloudBabel::TranslationObject.create({
                    object_type: 'controllers',
                    method: method,
                    section: 'messages',
                    translation: translation
                })

                ['label_1', 'label_2'].each do |label|
                    CloudBabel::TranslationObjectString.create({
                        label: label,
                        es: '',
                        en: '',
                        de: '',
                        fr: '',
                        translation_object: translation_object
                    })
                end
                

            end

        end        


=begin
        translation_files = Dir[Rails.root.join('config', 'locales', '**','**','**','**')]
        translation_files = Dir[Rails.root.join('config', 'locales', '*')]

        entries = YAML.load_file(translation_files[2]).first

        lang = entries[0]
        name_space = ''

        translation_file = Translation.find_or_create_by({
            file: translation_files[2]
        })

        def recursive_entry(entries, name_space, fileid)
            if entries.is_a?(Array)
                if entries[1].is_a?(Hash)
                    name_space = name_space + entries.first + '.'
                    recursive_entry(entries[1], name_space, fileid)
                else
                    TranslationString.create({
                        entry: name_space + entries[0],
                        lang_en: entries[1],
                        translations_id: fileid
                    })
                end
            end

            if entries.is_a?(Hash)
                entries.each do |entry|
                    if entry.is_a?(Array)
                        recursive_entry(entry, name_space, fileid)
                    end
                end
            end

        end

        recursive_entry(entries[1], lang + '.', translation_file.id)
=end
    end
end

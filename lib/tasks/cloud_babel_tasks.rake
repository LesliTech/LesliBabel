=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end

require "./lesli"
require 'json'

namespace :cloud_babel do

    desc "Create standard structure for translations according to the objects in the app"
    task scan: [:environment] do  

        translation_list = []

        # build core controller list
        translation_list = get_controllers_from_routes(translation_list, Rails.application.routes.routes, "Core")

        # build engines controller list
        translation_list = get_controllers_from_routes(translation_list, CloudTeam::Engine.routes.routes, CloudTeam) if defined?(CloudTeam)
        translation_list = get_controllers_from_routes(translation_list, CloudDriver::Engine.routes.routes, CloudDriver) if defined?(CloudDriver)
        translation_list = get_controllers_from_routes(translation_list, CloudHouse::Engine.routes.routes, CloudHouse) if defined?(CloudHouse)
        translation_list = get_controllers_from_routes(translation_list, CloudHaus::Engine.routes.routes, CloudHaus) if defined?(CloudHaus)
        translation_list = get_controllers_from_routes(translation_list, CloudLesli::Engine.routes.routes, CloudLesli) if defined?(CloudLesli)
        translation_list = get_controllers_from_routes(translation_list, CloudBell::Engine.routes.routes, CloudBell) if defined?(CloudBell)
        translation_list = get_controllers_from_routes(translation_list, CloudKb::Engine.routes.routes, CloudKb) if defined?(CloudKb)
        translation_list = get_controllers_from_routes(translation_list, CloudHelp::Engine.routes.routes, CloudHelp) if defined?(CloudHelp)
        translation_list = get_controllers_from_routes(translation_list, CloudPanel::Engine.routes.routes, CloudPanel) if defined?(CloudPanel)
        translation_list = get_controllers_from_routes(translation_list, CloudLock::Engine.routes.routes, CloudLock) if defined?(CloudLock)
        translation_list = get_controllers_from_routes(translation_list, CloudBabel::Engine.routes.routes, CloudBabel) if defined?(CloudBabel)

        translation_list.each do |t|

            p "object found: #{t[:module]}/#{t[:bucket]}"

            # Add object to the translation workflow
            translation_module = CloudBabel::Translation::Module.find_or_create_by({ name: t[:module] })
            translation_bucket = CloudBabel::Translation::Bucket.find_or_create_by({ name: t[:bucket], module: translation_module, reference_module: translation_module.name })

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

            controller_list.push({ module: engine, bucket: controller })
        end

        # shared engine translations 
        controller_list.push({ module: engine, bucket: 'shared' })

        return controller_list

    end

    desc "Generate translation files"
    task build: :environment do

        #Rake::Task["dev:db:babel_backup"].invoke

        files = { }

        available_langs = ['en', 'es', 'de']

        available_langs.each do |lang|
            files[lang] = { }
        end

        #CloudBabel::Translation::String.where(status: 1).each do |string|
        CloudBabel::Translation::String.all.each do |string|

            module_name = string.bucket.module.name
            bucket_name = string.bucket.name

            module_name_sym = module_name.downcase.sub('cloud', '')

            available_langs.each do |lang|

                file_path = Rails.root.join("config", "locales", bucket_name, "#{ bucket_name.gsub('/','_') }.#{ lang }.yml")

                if module_name != "Core"
                    file_path = Rails.root.join("engines", module_name, "config", "locales", bucket_name, "#{ bucket_name.gsub('/','_') }.#{ lang }.yml")
                end

                file_id = file_path.to_s.to_sym

                unless files[lang].has_key? file_id
                    files[lang][file_id] = { }
                end

                unless files[lang][file_id].has_key? module_name_sym
                    files[lang][file_id][module_name_sym] = { }
                end

                unless files[lang][file_id][module_name_sym].has_key? bucket_name
                    files[lang][file_id][module_name_sym][bucket_name] = { }
                end

                files[lang][file_id][module_name_sym][bucket_name][string.label] = string[lang]

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

    desc "Delete translation files"
    task clean: :environment do
        Lesli::engines.each do |engine|
            engine_path = Rails.root.join('engines', engine['name'], "config", "locales")
            FileUtils.rm_rf(engine_path)
            p "delete translations for: #{engine_path.to_s}"
        end
        engine_path = Rails.root.join("config", "locales")
        FileUtils.rm_rf(engine_path)
        p "delete translations for: #{engine_path.to_s}"
    end

end

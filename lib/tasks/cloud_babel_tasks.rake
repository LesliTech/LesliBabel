=begin

Lesli

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end

require "./lesli"
require 'json'

namespace :cloud_babel do

    desc "Delete translations files"
    task clean: [:environment] do  

        result = CloudBabel::TranslationsService.clean
        result.payload.each do |file_path|
            p "delete translations for: #{file_path.to_s}"
        end
        
    end

    desc "Create standard structure for translations according to the objects in the app"
    task scan: [:environment] do 

        instance = Rails.application.config.lesli_settings["instance"][:name]

        LC::System::Routes.scan.each do |t|

            # add object to the translation workflow
            translation_module = CloudBabel::Module.find_or_create_by({ name: t[:module], platform: t[:module_type] })
            translation_bucket = CloudBabel::Bucket.find_or_create_by({ name: t[:controller], module: translation_module, reference_module: translation_module.name })
            translation_bucket = CloudBabel::Bucket.find_or_create_by({ name: "shared", module: translation_module, reference_module: translation_module.name })

            # send debug message
            puts "object found: #{t[:module]}/#{t[:controller]}"

        end

    end

    desc ""
    task rails: [:environment] do 

        puts ""; puts "";
        puts "building rails translations"
        result = CloudBabel::TranslationsRailsService.build
        result.payload.each do |translation|
            puts translation[0]
        end
        puts ""; puts "";

    end

    desc ""
    task android: [:environment] do 

        puts ""; puts "";
        puts "building android translations"
        result = CloudBabel::TranslationsAndroidService.build
        result.payload.each do |translation|
            puts translation[0]
        end
        puts ""; puts "";

    end

    desc ""
    task ios: [:environment] do 

        puts ""; puts "";
        puts "building ios translations"
        result = CloudBabel::TranslationsIosService.build
        result.payload.each do |translation|
            puts translation[0]
        end
        puts ""; puts "";

    end

    desc ""
    task sync: [:environment] do 

        puts ""; puts "";
        puts "syncing translations"
        CloudBabel::TranslationsSynchronizationService.remote_sync
        puts ""; puts "";

    end
    
end

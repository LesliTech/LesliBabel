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

        Lesli::engines.each do |engine|
            engine_path = Rails.root.join("engines", engine["name"], "config", "locales")
            FileUtils.rm_rf(engine_path)
            p "delete translations for: #{engine_path.to_s}"
        end
        engine_path = Rails.root.join("config", "locales")
        FileUtils.rm_rf(engine_path)
        p "delete translations for: #{engine_path.to_s}"
    end

    desc "Create standard structure for translations according to the objects in the app"
    task scan: [:environment] do 

        LC::System::Routes.scan.each do |t|

            p "object found: #{t[:module]}/#{t[:bucket]}"

            # Add object to the translation workflow
            translation_module = CloudBabel::Translation::Module.find_or_create_by({ name: t[:module]})
            translation_bucket = CloudBabel::Translation::Bucket.find_or_create_by({ name: t[:bucket], module: translation_module, reference_module: translation_module.name })
            translation_bucket = CloudBabel::Translation::Bucket.find_or_create_by({ name: "shared", module: translation_module, reference_module: translation_module.name })

        end

    end
    
end

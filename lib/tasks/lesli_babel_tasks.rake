=begin

Lesli

Copyright (c) 2025, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

# · 
require "json"
require "i18n-js"
  

namespace :lesli_babel do

    desc "Delete translations files"
    task clean: [:environment] do  

        result = CloudBabel::TranslationsService.clean
        result.payload.each do |file_path|
            p "delete translations for: #{file_path.to_s}"
        end
        
    end

    desc "Create standard structure for translations according to the objects in the app"
    task scan: [:environment] do 

        engines = Lesli::ResourceService.new.index(matrix: true)

        engines.each do |engine, routes|

            platform = "lesli_engine"
            platform = "rails_app" if engine == "main_app"

            translation_module = LesliBabel::Module
            .create_with(:platform => platform)
            .find_or_create_by!(:code => engine)

            routes.each do |controller, route|

                LesliBabel::Bucket.find_or_create_by(
                    code: route[:route].sub("#{ engine }/", ""), 
                    module: translation_module, 
                    reference_module: translation_module.code
                )

                LesliBabel::Bucket.find_or_create_by(
                    code: "shared", 
                    module: translation_module, 
                    reference_module: translation_module.code
                )
            end
        end

        L2.info('LesliBabel: Module/Controllers scanned and registered')

    end


    desc "Export translations to json files"
    task :export => :environment do |task, args|

        LesliSystem.engines.each do |engine, engine_info|
            # You can provide the config directly using the following
            config = {
                "translations"=> [
                    { 
                        "file"=>"engines/#{engine}/lib/vue/stores/translations.json", 
                        "patterns"=>[
                            "!*.date",
                            "!*.devise",
                            "!*.faker",
                            "!*.flash",
                            "!*.helpers",
                            "!*.number",
                            "!*.views",
                            "!*.time",
                            "!*.support",
                            "!*.i18n",
                            "!*.activerecord",
                            "!*.errors",
                            "!*.number.nth",
                            "*.lesli.shared.*",
                            "*.lesli.dashboards.*",
                            "*.lesli.application.*",
                            "*.#{engine_info[:code]}.*",
                        ] 
                    }
                ]
            }

            pp I18nJS.call(config: config)
        end
    end 


    desc "Import local translations into LesliBabel"
    task :import => :environment do |task, args|

        # Get all the locally installed engines
        engines = LesliSystem.engines


        engines.each do |engine, engine_info|

            # cache the engine code
            engine_code = engine_info[:code]

            # platform name 
            platform = "lesli_engine"

            # create the babel module if it does not exists
            translation_module = LesliBabel::Module
            .create_with(:platform => platform)
            .find_or_create_by!(:code => engine_code)
            
            # Iterate over the available locales
            I18n.available_locales.each do |locale|

                # get the translations for an specific engine for an specific locale
                translations = I18n.t(engine_code, locale: locale)

                # check if the translations is an object
                next unless translations.class == Hash
                translations.each do |bucket, labels|

                    # create the bucket if it does not exist
                    translation_bucket = LesliBabel::Bucket.find_or_create_by(
                        code: bucket, 
                        module: translation_module, 
                        reference_module: translation_module.code
                    )

                    labels.each do |label, translation|

                        # create or get the label
                        label = LesliBabel::Label.create_with(
                            reference_bucket: "#{translation_module.code}-#{translation_bucket.code}"
                        ).find_or_create_by(
                            text: label,
                            bucket_id: translation_bucket.id
                        )

                        # do not save strings with template translation
                        next if translation.match?(/\A:.*:\z/) rescue false

                        label.update(locale => translation)
                    end
                end 
            end
        end
    end
end

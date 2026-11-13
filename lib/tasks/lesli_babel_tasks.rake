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
#require "i18n-js"
  

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

        Termline.success('LesliBabel: Module/Controllers scanned and registered')

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

            #pp I18nJS.call(config: config)
        end
    end 


    desc "Import local translations into LesliBabel"
    task import: :environment do

        # Discover every translation file and determine its platform
        translation_files = LesliSystem.engines.values.flat_map do |engine_info|
            platform = case engine_info[:code]
            when "root"
                "rails_app"
            when "lesli"
                "lesli_core"
            else
                "lesli_engine"
            end

            Dir[File.join(engine_info[:dir], "config", "locales", "translations.*.yml")].map do |file_path|
                {
                    engine: engine_info[:name],
                    file: File.basename(file_path),
                    path: file_path,
                    platform: platform
                }
            end
        end.sort_by { |translation_file| [translation_file[:engine], translation_file[:file]] }

        Termline.info("Translation files discovered", files: translation_files.size)

        # Accumulate the results returned by every imported file
        total = {
            files: 0,
            created: {
                modules: 0,
                buckets: 0,
                labels: 0
            },
            completed: 0,
            skipped: 0,
            errors: []
        }

        translation_files.each do |translation_file|
            result = LesliBabel::TranslationImportService.call(
                file_path: translation_file[:path],
                platform: translation_file[:platform]
            )

            total[:files] += 1
            total[:created].each_key do |resource|
                total[:created][resource] += result[:created][resource]
            end
            total[:completed] += result[:completed]
            total[:skipped] += result[:skipped]
            total[:errors].concat(
                result[:errors].map do |error|
                    "#{translation_file[:engine]}/#{translation_file[:file]}: #{error}"
                end
            )

            summary = {
                engine: translation_file[:engine],
                file: translation_file[:file]
            }

            if result[:errors].empty?
                Termline.success("Translations imported", **summary)
            else
                Termline.warning("Translations imported with rejected entries", **summary)
                Termline.list(*result[:errors], color: :yellow, icon: :warning)
            end
        end

        summary = {
            files_processed: total[:files],
            modules_created: total.dig(:created, :modules),
            buckets_created: total.dig(:created, :buckets),
            labels_created: total.dig(:created, :labels),
            translations_completed: total[:completed],
            translations_skipped: total[:skipped],
            structural_errors: total[:errors].size
        }

        if total[:errors].any?
            Termline.danger("Translation import finished with errors", **summary)
            raise LesliBabel::TranslationImportService::InvalidStructureError,
                "Translation import rejected #{total[:errors].size} invalid entries"
        end

        Termline.success("Translation import completed", **summary)
    end
end

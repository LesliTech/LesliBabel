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
require "fileutils"
require "tmpdir"
  

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

            module_code = engine == "rails_app" ? "main_app" : engine
            platform = case engine
            when "rails_app"
                "rails_app"
            when "lesli"
                "lesli_core"
            else
                "lesli_engine"
            end

            translation_module = LesliBabel::Module
                .find_or_create_by!(code: module_code, platform: platform)

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


    desc "Export translations without modifying installed engines"
    task :export, [:output_dir] => :environment do |_task, args|

        # Generate every document before writing to the output directory
        documents = LesliSystem.engines.values
            .sort_by { |engine| engine[:name].to_s }
            .flat_map do |engine|
            platform = case engine[:code]
            when "root"
                "rails_app"
            when "lesli"
                "lesli_core"
            else
                "lesli_engine"
            end

            export_engine = engine[:code] == "root" ? engine.merge(code: "main_app") : engine

            Lesli.config.babel.fetch(:locales).keys.map(&:to_s).sort.map do |locale|
                {
                    engine: engine,
                    document: LesliBabel::TranslationExportService.call(
                        engine: export_engine,
                        platform: platform,
                        locale: locale
                    )
                }
            end
        end

        output_dir = File.expand_path(args[:output_dir].presence || Dir.mktmpdir("lesli-babel-export"))

        documents.each do |export|
            engine = export.fetch(:engine)
            document = export.fetch(:document)
            engine_dir = File.join(output_dir, engine.fetch(:code))
            file_name = File.basename(document.fetch(:file_path))

            FileUtils.mkdir_p(engine_dir)
            File.binwrite(File.join(engine_dir, file_name), document.fetch(:content))

            Termline.success("Translations exported", engine: engine[:name], file: file_name)
        end

        Termline.success("Translation export completed", directory: output_dir)
    end 


    desc "Deploy translations to installed engines"
    task deploy: :environment do

        result = LesliBabel::TranslationDeployService.call

        if result[:errors].any?
            Termline.danger("Translation deploy failed")
            Termline.list(*result[:errors], color: :red, icon: :warning)
            raise "Translation deploy failed"
        end

        engines = LesliSystem.engines.values

        result[:files].each do |file_path|
            engine = engines.find do |engine_info|
                file_path.start_with?("#{engine_info[:dir]}#{File::SEPARATOR}")
            end

            Termline.success(
                "Translations deployed",
                engine: engine&.dig(:name),
                file: File.basename(file_path)
            )
        end

        Termline.success("Translation deploy completed")
    end


    desc "Import local translations into LesliBabel"
    task :import, [:silent] => :environment do |_task, args|

        silent = ActiveModel::Type::Boolean.new.cast(args[:silent])

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

        errors = []

        translation_files.each do |translation_file|
            result = LesliBabel::TranslationImportService.call(
                file_path: translation_file[:path],
                platform: translation_file[:platform]
            )

            errors.concat(
                result[:errors].map do |error|
                    "#{translation_file[:engine]}/#{translation_file[:file]}: #{error}"
                end
            )

            next if silent

            file_details = {
                engine: translation_file[:engine],
                file: translation_file[:file]
            }

            if result[:errors].empty?
                Termline.success("Translations imported", **file_details)
            else
                Termline.warning("Translations imported with rejected entries", **file_details)
                Termline.list(*result[:errors], color: :yellow, icon: :warning)
            end
        end

        # Show this single message to know the status of the import task
        if errors.any?
            Termline.danger("LesliBabel: Translations imported with errors")
        else
            Termline.success("LesliBabel: Translations imported successfully")
        end
    end
end

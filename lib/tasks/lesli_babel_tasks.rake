=begin

Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

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

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

# · 
require "json"
namespace :lesli_babel do

    desc "Delete translations files"
    task clean: [:environment] do  

        result = CloudBabel::TranslationsService.clean
        result.payload.each do |file_path|
            p "delete translations for: #{file_path.to_s}"
        end
        
    end

    desc "Create standard structure for translations according to the objects in the app"
    task build: [:environment] do 

        engines = Lesli::SystemController.index(matrix: false)

        engines.each do |t|

            platform = "lesli_engine"
            platform = "lesli_core" if t[:engine] == "lesli"

            # add object to the translation workflow
            translation_module = LesliBabel::Module.find_or_create_by(code: t[:engine], platform: platform)
            translation_bucket = LesliBabel::Bucket.find_or_create_by(code: t[:route].sub(t[:engine]+"/", ""), module: translation_module, reference_module: translation_module.code)
            translation_bucket = LesliBabel::Bucket.find_or_create_by(code: "shared", module: translation_module, reference_module: translation_module.code)

        end 

        L2.msg "CloudBabel: Module/Controllers scanned and registered"

    end
end

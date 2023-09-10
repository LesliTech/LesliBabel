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

class CreateLesliBabelStringDiscussions < ActiveRecord::Migration[7.0]
    def change
        # create_table :lesli_babel_string_discussions do |t|
        #     table_base_structure = JSON.parse(File.read(Rails.root.join("db","structure","00000005_discussions.json")))
        #     table_base_structure.each do |column|
        #         t.send(
        #             column["type"].parameterize.underscore.to_sym,
        #             column["name"].parameterize.underscore.to_sym
        #         )
        #     end
            
        #     t.text :reference_module_bucket_string
        #     t.timestamps
        # end
        # add_index :cloud_babel_string_discussions, :reference_module_bucket_string, name: :babel_string_discussions_module_bucket_string
        # add_reference :cloud_babel_string_discussions, :users, foreign_key: true
        # add_reference :cloud_babel_string_discussions, :cloud_babel_string_discussions, foreign_key: true, index: { name: "babel_string_discussions_discussions" }
        # add_reference :cloud_babel_string_discussions, :cloud_babel_strings, foreign_key: true, index: { name: "babel_module_discussions_strings" }
    end
end

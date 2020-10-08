class CreateCloudBabelStringDiscussions < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_string_discussions do |t|
            table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000005_discussions.json')))
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_babel_string_discussions, :users, foreign_key: true
        add_reference :cloud_babel_string_discussions, :cloud_babel_string_discussions, foreign_key: true, index: { name: "babel_string_discussions_discussions" }
        add_reference :cloud_babel_string_discussions, :cloud_babel_strings, foreign_key: true, index: { name: "babel_module_discussions_strings" }
    end
end

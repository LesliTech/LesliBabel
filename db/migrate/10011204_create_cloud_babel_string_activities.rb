class CreateCloudBabelStringActivities < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000004_activities.json')))
        create_table :cloud_babel_string_activities do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end

            t.text :reference_module_bucket_string
            t.timestamps
        end
        add_index :cloud_babel_string_activities, :reference_module_bucket_string, name: :babel_string_activities_module_bucket_string
        add_reference :cloud_babel_string_activities, :cloud_babel_strings, foreign_key: true, index: { name: "babel_string_activities_strings"}
    end
end

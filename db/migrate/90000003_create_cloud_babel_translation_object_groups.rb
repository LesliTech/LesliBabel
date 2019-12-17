class CreateCloudBabelTranslationObjectGroups < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_object_groups do |t|
            t.string    :method 
            t.string    :section 
            t.timestamps
        end
        add_reference :cloud_babel_translation_object_groups, :cloud_babel_translation_objects, foreign_key: true, index: { name: "babel_translation_object_groups_objects" }
    end
end

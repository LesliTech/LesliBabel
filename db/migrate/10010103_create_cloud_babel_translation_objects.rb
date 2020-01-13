class CreateCloudBabelTranslationObjects < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_objects do |t|
            t.string :name
            t.string :object_type
            t.timestamps
        end
        add_reference :cloud_babel_translation_objects, :cloud_babel_translation_objects, foreign_key: true, index: { name: "cloud_babel_translation_objects_objects" }
        add_reference :cloud_babel_translation_objects, :cloud_babel_translation_modules, foreign_key: true, index: { name: "babel_translation_objects_modules" }
    end
end

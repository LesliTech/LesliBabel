class CreateCloudBabelTranslationObjects < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_objects do |t|
            t.string    :object_type 
            t.string    :method 
            t.string    :section 
            t.timestamps
        end
        add_reference :cloud_babel_translation_objects, :cloud_babel_translations, foreign_key: true, index: { name: "babel_translations_translation_objects" }
    end
end

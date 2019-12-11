class CreateCloudBabelTranslationObjects < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_objects do |t|
            t.string    :type 
            t.string    :method 
            t.string    :section 
            t.timestamps
        end
        add_reference :cloud_babel_translations, :cloud_babel_translation_objects, foreign_key: true, index: { name: "babel_translations_translation_objects" }
    end
end

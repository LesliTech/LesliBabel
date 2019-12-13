class CreateCloudBabelTranslationObjectStrings < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_object_strings do |t|
            t.string    :label
            t.string    :es
            t.string    :en
            t.string    :de
            t.string    :fr
            t.timestamps
        end
        add_reference :cloud_babel_translation_object_strings, :cloud_babel_translation_objects, foreign_key: true, index: { name: "babel_translation_objects_translation_object_strings" }, on_delete: :cascade
    end
end

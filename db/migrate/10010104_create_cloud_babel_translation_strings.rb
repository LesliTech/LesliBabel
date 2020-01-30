class CreateCloudBabelTranslationStrings < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_strings do |t|
            t.string    :context
            t.string    :label
            t.string    :es
            t.string    :en
            t.string    :de
            t.string    :fr
            t.integer   :status
            t.timestamps
        end
        add_reference :cloud_babel_translation_strings, :users, foreign_key: true, index: { name: "babel_translation_strings_users" }
        add_reference :cloud_babel_translation_strings, :cloud_babel_translation_buckets, foreign_key: true, index: { name: "babel_translation_strings_buckets" }
    end
end

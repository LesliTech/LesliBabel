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
            t.string    :reference_bucket
            t.datetime  :last_update_context
            t.datetime  :last_update_es
            t.datetime  :last_update_en
            t.datetime  :last_update_de
            t.datetime  :last_update_fr
            t.datetime  :last_update_status
            t.datetime  :deleted_at
            t.timestamps
        end
        add_reference :cloud_babel_translation_strings, :users, foreign_key: true, index: { name: "babel_translation_strings_users" }
        add_reference :cloud_babel_translation_strings, :cloud_babel_translation_buckets, foreign_key: true, index: { name: "babel_translation_strings_buckets" }
    end
end

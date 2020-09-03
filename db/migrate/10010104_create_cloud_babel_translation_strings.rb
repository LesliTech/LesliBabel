class CreateCloudBabelTranslationStrings < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_strings do |t|
            t.string    :label
            t.string    :es #spanish
            t.string    :en #english
            t.string    :de #deutsch/german
            t.string    :fr #french
            t.string    :nl #nederlands/netherlands/holanda
            t.string    :pl #polski/polish/poland
            t.string    :pt #portuguese
            t.string    :it #italian
            t.string    :tr #turkish
            t.string    :ro #romanian
            t.string    :bg #bulgarian
            t.string    :context
            t.integer   :priority
            t.boolean   :help_needed
            t.boolean   :help_translation
            t.string    :reference_bucket
            t.datetime  :last_update_es
            t.datetime  :last_update_en
            t.datetime  :last_update_de
            t.datetime  :last_update_fr
            t.datetime  :last_update_nl
            t.datetime  :last_update_pl
            t.datetime  :last_update_pt
            t.datetime  :last_update_it
            t.datetime  :last_update_tr
            t.datetime  :last_update_ro
            t.datetime  :last_update_bg
            t.datetime  :last_update_status
            t.datetime  :last_update_context
            t.datetime  :last_update_priority
            t.datetime  :deleted_at
            t.timestamps
        end
        add_reference :cloud_babel_translation_strings, :users, foreign_key: true, index: { name: "babel_translation_strings_users" }
        add_reference :cloud_babel_translation_strings, :cloud_babel_translation_buckets, foreign_key: true, index: { name: "babel_translation_strings_buckets" }
    end
end

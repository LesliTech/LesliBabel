class CreateCloudBabelStrings < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_strings do |t|

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

            t.string    :status
            t.string    :context
            t.string    :priority
            t.boolean   :need_help
            t.boolean   :need_translation

            t.datetime  :last_update_status
            t.datetime  :last_update_context
            t.datetime  :last_update_priority
            t.datetime  :last_update_need_help
            t.datetime  :last_update_need_translation

            t.string    :reference_instance
            t.string    :reference_module_bucket
            t.datetime  :deleted_at
            t.timestamps
        end
        add_reference :cloud_babel_strings, :users, foreign_key: true
        add_reference :cloud_babel_strings, :cloud_babel_buckets, foreign_key: true
    end
end

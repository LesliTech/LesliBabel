class Languages < ActiveRecord::Migration[6.0]
    def change
        add_column :cloud_babel_translation_strings, :nl, :string
        add_column :cloud_babel_translation_strings, :pl, :string
        add_column :cloud_babel_translation_strings, :pt, :string
        add_column :cloud_babel_translation_strings, :tr, :string
        add_column :cloud_babel_translation_strings, :ro, :string
        add_column :cloud_babel_translation_strings, :ro, :string
        add_column :cloud_babel_translation_strings, :bg, :string

        add_column :cloud_babel_translation_strings, :last_update_nl, :datetime
        add_column :cloud_babel_translation_strings, :last_update_pl, :datetime
        add_column :cloud_babel_translation_strings, :last_update_pt, :datetime
        add_column :cloud_babel_translation_strings, :last_update_tr, :datetime
        add_column :cloud_babel_translation_strings, :last_update_ro, :datetime
        add_column :cloud_babel_translation_strings, :last_update_ro, :datetime
        add_column :cloud_babel_translation_strings, :last_update_bg, :datetime

        remove_column :cloud_babel_translation_strings, :need_help
        remove_column :cloud_babel_translation_strings, :need_translation

        add_column :cloud_babel_translation_modules, :module_type, :string
    end
end

=begin

Lesli

Copyright (c) 2026, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

class CreateLesliBabelLabels < ActiveRecord::Migration[7.2]
    def change
        create_table :lesli_babel_labels do |t|

            t.string    :text, null: false
            t.string    :status
            t.text      :context

            t.text      :es # spanish
            t.text      :en # english
            t.text      :de # deutsch/german
            t.text      :fr # french
            t.text      :nl # nederlands/netherlands/holanda
            t.text      :pl # polski/polish/poland
            t.text      :pt # portuguese
            t.text      :it # italian
            t.text      :tr # turkish
            t.text      :ro # romanian
            t.text      :bg # bulgarian
            t.text      :uk # Ukrainian
            t.text      :sr # Serbian
            t.text      :hr # Hrvatski/Croatian

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
            t.datetime  :last_update_uk
            t.datetime  :last_update_sr
            t.datetime  :last_update_hr

            t.datetime  :last_update_status
            t.datetime  :last_update_context

            t.string :reference_bucket, null: false

            t.datetime  :deleted_at
            t.timestamps
        end
        add_reference(:lesli_babel_labels, :bucket, null: false, foreign_key: { to_table: :lesli_babel_buckets })
        add_index(:lesli_babel_labels, %i[bucket_id text], unique: true, where: "deleted_at IS NULL", name: "idx_babel_labels_unique_active_bucket_text")
        add_index(:lesli_babel_labels, :status, name: "idx_babel_labels_on_status")
        add_index(:lesli_babel_labels, :deleted_at)
    end
end

class CreateCloudBabelTranslationObjectGroupSectionLabels < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_object_group_section_labels do |t|
            t.string    :context
            t.string    :label
            t.string    :es
            t.string    :en
            t.string    :de
            t.string    :fr
            t.integer   :status
            t.timestamps
        end
        add_reference :cloud_babel_translation_object_group_section_labels, :users, foreign_key: true, index: { name: "babel_translation_object_group_section_labels_users" }
        add_reference :cloud_babel_translation_object_group_section_labels, :cloud_babel_translations, foreign_key: true, index: { name: "babel_translation_object_group_section_labels_translations" }
        add_reference :cloud_babel_translation_object_group_section_labels, :cloud_babel_translation_object_group_sections, foreign_key: true, index: { name: "babel_translation_object_group_section_labels_sections" }
    end
end

class CreateCloudBabelTranslationObjectGroupLabels < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_object_group_labels do |t|
            t.string    :context
            t.string    :label
            t.string    :es
            t.string    :en
            t.string    :de
            t.string    :fr
            t.integer   :status # waiting for translation, # ready for review, # done
            t.timestamps
        end
        add_reference :cloud_babel_translation_object_group_labels, :users, foreign_key: true, index: { name: "babel_translation_object_group_labels_users" }
        add_reference :cloud_babel_translation_object_group_labels, :cloud_babel_translation_object_groups, foreign_key: true, index: { name: "babel_translation_object_group_labels_groups" }
    end
end
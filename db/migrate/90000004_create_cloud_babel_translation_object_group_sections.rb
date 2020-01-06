class CreateCloudBabelTranslationObjectGroupSections < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_object_group_sections do |t|
            t.string    :name 
            t.timestamps
        end
        add_reference :cloud_babel_translation_object_group_sections, :cloud_babel_translation_object_groups, foreign_key: true, index: { name: "babel_translation_object_group_sections_groups" }
    end
end

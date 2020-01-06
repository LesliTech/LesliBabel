module CloudBabel
    class TranslationObjectGroupSection < ApplicationRecord
        belongs_to :group, class_name: "TranslationObjectGroup", foreign_key: "cloud_babel_translation_object_groups_id"
        has_many :labels, class_name: "TranslationObjectGroupSectionLabel", foreign_key: "cloud_babel_translation_object_group_sections_id", :dependent => :delete_all
    end
end

module CloudBabel
    class TranslationObjectGroupLabel < ApplicationRecord
        belongs_to :group, class_name: 'TranslationObjectGroup', foreign_key: "cloud_babel_translation_object_groups_id"
    end
end

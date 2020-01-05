module CloudBabel
    class TranslationObjectGroupLabel < ApplicationRecord
        belongs_to :group, class_name: 'TranslationObjectGroup', foreign_key: 'cloud_babel_translation_object_groups_id'
        belongs_to :user, class_name: '::User', foreign_key: 'users_id'
    end
end

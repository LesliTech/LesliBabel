module CloudBabel
    class TranslationObjectGroup < ApplicationRecord
        belongs_to :object, class_name: 'TranslationObject', foreign_key: "cloud_babel_translation_objects_id"
        has_many :sections, class_name: "TranslationObjectGroupSection", foreign_key: "cloud_babel_translation_object_groups_id", :dependent => :delete_all
    end
end

module CloudBabel
    class TranslationObjectGroup < ApplicationRecord
        belongs_to :object, class_name: 'TranslationObject', foreign_key: "cloud_babel_translation_objects_id"
        has_many :labels, class_name: "TranslationObjectGroupLabel", foreign_key: "cloud_babel_translation_object_groups_id", :dependent => :delete_all
    end
end

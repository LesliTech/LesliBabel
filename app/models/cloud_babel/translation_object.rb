module CloudBabel
    class TranslationObject < ApplicationRecord
        belongs_to :translation, foreign_key: "cloud_babel_translations_id"
        has_many :groups, class_name: "TranslationObjectGroup", foreign_key: "cloud_babel_translation_objects_id", :dependent => :delete_all
    end
end

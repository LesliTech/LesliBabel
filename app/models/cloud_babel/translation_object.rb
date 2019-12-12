module CloudBabel
    class TranslationObject < ApplicationRecord
        belongs_to :translation, foreign_key: "cloud_babel_translations_id"
        has_many :translation_object_strings, foreign_key: "cloud_babel_translation_objects_id"
    end
end

module CloudBabel
    class TranslationObjectString < ApplicationRecord
        belongs_to :translation_object, foreign_key: "cloud_babel_translation_objects_id"
    end
end

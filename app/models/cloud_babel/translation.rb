module CloudBabel
    class Translation < ApplicationRecord
        has_many :objects, class_name: "TranslationObject", foreign_key: "cloud_babel_translations_id", dependent: :destroy
    end
end

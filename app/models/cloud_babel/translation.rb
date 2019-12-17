module CloudBabel
    class Translation < ApplicationRecord
        has_many :translation_objects, foreign_key: "cloud_babel_translations_id", dependent: :destroy
    end
end

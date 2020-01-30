module CloudBabel
    class Translation::Module < ApplicationRecord
        has_many :buckets, foreign_key: "cloud_babel_translation_modules_id"
    end
end

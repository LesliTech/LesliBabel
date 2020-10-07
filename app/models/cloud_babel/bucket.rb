module CloudBabel
    class Bucket < ApplicationRecord
        belongs_to :module, foreign_key: "cloud_babel_modules_id"
    end
end

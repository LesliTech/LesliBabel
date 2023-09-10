module LesliBabel
    class Bucket < ApplicationRecord
        belongs_to :module, foreign_key: "cloud_babel_modules_id"

        has_many :strings,  foreign_key: "cloud_babel_buckets_id"
    end
end

module LesliBabel
    class Bucket < ApplicationRecord
        belongs_to :module
        has_many :strings
    end
end

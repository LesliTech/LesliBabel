module LesliBabel
    class Bucket < ApplicationRecord
        belongs_to :module
        has_many :labels
    end
end

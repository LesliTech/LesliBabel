module CloudBabel
    class Translation::Module < ApplicationRecord
        has_many :buckets, foreign_key: "cloud_babel_translation_modules_id"

        def self.index 
            Translation::Module.all
        end

    end
end

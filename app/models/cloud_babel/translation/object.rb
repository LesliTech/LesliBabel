module CloudBabel
    class Translation::Object < ApplicationRecord
        belongs_to :module, foreign_key: "cloud_babel_translation_modules_id", optional: true
        belongs_to :parent, class_name: "Translation::Object", foreign_key: "cloud_babel_translation_objects_id", optional: true
        has_many :children, class_name: "Translation::Object", foreign_key: "cloud_babel_translation_objects_id"
        has_many :strings, foreign_key: "cloud_babel_translation_objects_id"
    end
end

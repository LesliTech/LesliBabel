module CloudBabel
    class String::Discussion < CloudObject::Discussion
        belongs_to :cloud_object, class_name: "String", foreign_key: "cloud_babel_strings_id"
        belongs_to :parent, class_name: "Discussion", optional: true
        has_many :children, class_name: "Discussion", foreign_key: "parent_id"
    end
end

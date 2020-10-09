module CloudBabel
    class String::Activity < CloudObject::Activity
        belongs_to :cloud_object, class_name: "String", foreign_key: "cloud_babel_strings_id", optional: true
    end
end

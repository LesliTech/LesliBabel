module CloudBabel
    class Translation::String < ApplicationRecord
        belongs_to :user, foreign_key: "users_id", optional: true
        belongs_to :bucket, foreign_key: "cloud_babel_translation_buckets_id"

        before_save :clean_label_string

        def clean_label_string
            self.label = self.label
                .downcase                           # string to lowercase
                .gsub(/[^0-9A-Za-z\s\-\_]/, '')     # remove special characters from string
                .gsub(/-/, '_')                     # replace dashes with underscore
                .gsub(/\s+/, '_')                   # replace spaces or spaces with single dash

            self.status = "normal" if self.status.nil? or self.status == ""
            self.priority = "normal" if self.priority.nil? or self.priority == ""
        end

        def path
            [
                self.bucket.module.name.downcase.sub("cloud",""),
                self.bucket.name.downcase,
                self.label.downcase
            ].join(".")
        end

    end
end

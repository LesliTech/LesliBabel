module LesliBabel
    class Label < ApplicationRecord
        belongs_to :bucket

        before_create :prepare_label

        enum :status, {
            :ok => "ok",
            :disabled => "disabled",
            :need_help => "need_help",
            :need_context => "need_context",
            :need_translation => "need_translation"
        }

        private

        def prepare_label

            self.text = self.text
                .downcase                           # string to lowercase
                .gsub(/[^0-9A-Za-z\s\-\_]/, '')     # remove special characters from string
                .gsub(/-/, '_')                     # replace dashes with underscore
                .gsub(/\s+/, '_')                   # replace spaces or spaces with single dash

            self.reference_bucket = "#{self.bucket.reference_module}-#{self.bucket.code}"
        end
    end
end

module LesliBabel
    class Label < ApplicationRecord
        attribute :prefix, :string

        belongs_to :bucket

        before_create :prepare_label

        enum :status, {
            :ok => "ok",
            :need_help => "need_help",
            :need_context => "need_context",
            :need_translation => "need_translation"
        }, validate: { allow_nil: true }

        enum :prefix, {

            # database
            :column => "column",
            
            # layout
            :navigation => "navigation",

            # components & elements
            :button => "button",
            :chart => "chart",
            :tab => "tab",
            :table => "table",
            :toolbar => "toolbar",

            # general
            :view => "view",
            :message => "message"
        }, prefix: true

        def category
            return "warning" if need_help?
            return "info"    if need_context?
            return "danger"  if need_translation?
            "ok"
        end

        def translation_path
            return self[:path] if has_attribute?(:path) && self[:path].present?

            [translation_module_code, translation_bucket_code, text].join(".")
        end

        def translation_module_code
            return self[:engine_code] if has_attribute?(:engine_code)

            bucket.module.code
        end

        def translation_bucket_code
            return self[:bucket_code] if has_attribute?(:bucket_code)

            bucket.code
        end

        private

        def prepare_label

            self.text = [self.prefix, self.text].compact.join('_')
                .downcase                           # string to lowercase
                .gsub(/[^0-9A-Za-z\s\-\_]/, '')     # remove special characters from string
                .gsub(/-/, '_')                     # replace dashes with underscore
                .gsub(/\s+/, '_')                   # replace spaces or spaces with single dash

            self.reference_bucket = "#{self.bucket.reference_module}-#{self.bucket.code}"
        end
    end
end

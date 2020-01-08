module CloudBabel
    class TranslationObjectGroupSectionLabel < ApplicationRecord
        belongs_to :object,  class_name: 'Translation', foreign_key: 'cloud_babel_translations_id', optional: true
        belongs_to :section, class_name: 'TranslationObjectGroupSection', foreign_key: 'cloud_babel_translation_object_group_sections_id', optional: true
        belongs_to :user, class_name: '::User', foreign_key: 'users_id'

        before_save :clean_label_string

        def clean_label_string
            self.label = self.label
                .downcase                       # string to lowercase
                .gsub(/[^0-9A-Za-z\s\-]/, '')   # remove special characters from string
                .gsub(/-/, '_')                 # replace dashes with underscore
                .gsub(/\s+/, '_')               # replace spaces or spaces with single dash
        end

    end
end

module CloudBabel
    class Module < ApplicationRecord
        has_many :buckets, foreign_key: "cloud_babel_modules_id"

        before_create :format_module_name

        def self.index 
            Module.where("name is not null").map do |translation_module|
                {
                    id: translation_module[:id],
                    name: translation_module[:name],
                    code: translation_module[:name].downcase,
                    type: translation_module[:module_type]
                }
            end
        end

        def format_module_name
            self.name = self.name
            .gsub(/[^0-9A-Za-z\s\-\_]/, '')  # remove special characters from string
            .gsub(/-/, '')                   # replace dashes with underscore
            .gsub(/_/, '')                   # replace underscore with underscore
            .titlecase                       # Capitalizes all the words
            .gsub(/\s+/, '')                 # remove blank spaces
        end 

    end
end

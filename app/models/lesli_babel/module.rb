module LesliBabel
    class Module < ApplicationRecord
        has_many :buckets
        has_many :labels

        validates_presence_of :platform

        before_create :format_module_name

        def self.index 
            Module.where("name is not null")
            order(id: :desc).map do |translation_module|
                {
                    id: translation_module[:id],
                    name: translation_module[:name],
                    code: translation_module[:name].downcase,
                    platform: translation_module[:platform]
                }
            end
        end

        def format_module_name

            return if self.code == "main_app"
            return if self.platform == "lesli_core"
            return if self.platform == "lesli_engine"

            self.code = self.code
            .gsub(/[^0-9A-Za-z\s\-\_]/, '')  # remove special characters from string
            .gsub(/-/, '')                   # replace dashes with underscore
            .gsub(/_/, '')                   # replace underscore with underscore
            .gsub(/\s+/, '')                 # remove blank spaces
        end 
    end
end

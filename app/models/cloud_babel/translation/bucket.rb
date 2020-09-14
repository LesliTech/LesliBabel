=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end

module CloudBabel
    class Translation::Bucket < ApplicationRecord
        belongs_to :module, foreign_key: "cloud_babel_translation_modules_id", optional: true
        belongs_to :parent, class_name: "Translation::Bucket", foreign_key: "cloud_babel_translation_buckets_id", optional: true
        has_many :children, class_name: "Translation::Bucket", foreign_key: "cloud_babel_translation_buckets_id"
        has_many :strings, foreign_key: "cloud_babel_translation_buckets_id"

        before_save :format_bucket_name

        def format_bucket_name
            self.name = self.name
                .downcase                           # string to lowercase
                .gsub(/[^0-9A-Za-z\s\-\_\/]/, '')   # remove special characters from string
                .gsub(/-/, '_')                     # replace dashes with underscore
                .gsub(/\s+/, '/')                   # replace spaces or spaces with single dash
        end

    end
end

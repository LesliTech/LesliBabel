module CloudBabel
    class Translation::String < ApplicationRecord
        belongs_to :user, foreign_key: "users_id", optional: true
        belongs_to :bucket, foreign_key: "cloud_babel_translation_buckets_id"

        before_save :clean_label_string

        def self.index current_user, query, params

            # empty strings by default
            strings = []

            # if bucket or module was not sent, return all the strings in the database with missing german translation
            if params[:module_id].blank? and params[:bucket_id].blank?

                sql_where_condition = []

                # add filter to select only available languages 
                Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|
                    sql_where_condition.push("#{locale} is NULL")
                    sql_where_condition.push("#{locale} = ''")
                end

                sql_where_condition.push("need_help = TRUE")
                sql_where_condition.push("need_translation = TRUE")

                strings = Translation::String.where(sql_where_condition.join(" OR "))

            end

            # returns strings for specif module
            if not params[:module_id].blank? and params[:bucket_id].blank?
                strings = Translation::String.joins(:bucket)
                    .where("cloud_babel_translation_buckets.cloud_babel_translation_modules_id = ?", params[:module_id])
            end

            # returns strings for specif module and bucket
            if not params[:module_id].blank? and not params[:bucket_id].blank?
                bucket = Translation::Bucket.find(params[:bucket_id])
                strings = bucket.strings
            end

            strings = strings.select(
                :id,
                :label,
                :status,
                :context,
                :priority,
                :need_help,
                :need_translation,
                Rails.application.config.lesli_settings["configuration"]["locales"],
                "'' as path",
                :cloud_babel_translation_buckets_id,
                :reference_bucket
            )

            count = strings.length

            strings = strings
            .page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
            .order(:updated_at)

            LC::Response.pagination(
                strings.current_page,
                strings.total_pages,
                strings.total_count,
                strings.length,
                strings.map do |string|
                    string["path"] = "ldonis"
                    string
                end
            )

        end

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
            return "full_path"
            self
            .reference_bucket
            .downcase
            #.gsub(/\bcloud/,"") # removes cloud only at start of string
            .gsub("cloud","") # removes cloud only at start of string
            .sub("-",".")
            .concat(".")
            .concat(self.label)
        end

    end
end

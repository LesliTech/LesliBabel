module CloudBabel
    class String < ApplicationRecord
        belongs_to :user, foreign_key: "users_id", optional: true
        belongs_to :bucket, foreign_key: "cloud_babel_buckets_id"

        before_create :clean_label_string

        def self.index current_user, query, params

            strings = []

            # if bucket or module was not sent, return all the strings in the database with missing german translation
            if params[:module_id].blank?

                sql_where_condition = []

                # add filter to select only available languages 
                Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|
                    sql_where_condition.push("#{locale} is NULL")
                    sql_where_condition.push("#{locale} = ''")
                end

                sql_where_condition.push("need_help = TRUE")
                sql_where_condition.push("need_translation = TRUE")

                strings = TranslationsService.strings().where(sql_where_condition.join(" OR "))
            end

            # returns strings for specif module with optional bucket
            if not params[:module_id].blank?
                strings = TranslationsService.strings(params[:module_id], params[:bucket_id])
            end

            strings = strings
            .page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
            .order(:updated_at)

            LC::Response.pagination(
                strings.current_page,
                strings.total_pages,
                strings.total_count,
                strings.length,
                strings
            )

        end

        def self.stats

            # total translations registered in babel
            total_strings = String.all.count

            # total translations by language
            total_strings_translations = []
            
            Rails.application.config.lesli_settings["configuration"]["locales_available"].each do |locale|
                total_strings_translations.push({
                    code: locale[0],
                    name: locale[1],
                    total: 0 #String.where("#{locale[0]} is not null").where("#{locale[0]} != ''").count
                })
            end

            # total translations that needs help
            total_strings_waiting_for_help = 0 #String.where(:need_help => true).count

            # total translations that needs translation
            total_strings_waiting_for_translation = 3 #String.where(:need_translation => true).count
            
            last_synchronization_at = "Not synchronized"
            last_synchronization_at = "" #LC::Date.to_string_datetime(Translation.first.updated_at) if not Translation.first.blank?

            {
                total_strings: total_strings,
                total_strings_translations: total_strings_translations,
                total_strings_waiting_for_help: total_strings_waiting_for_help,
                total_strings_waiting_for_translation: total_strings_waiting_for_translation,
                last_synchronization_at: last_synchronization_at
            }

        end

        private

        def clean_label_string

            self.label = self.label
                .downcase                           # string to lowercase
                .gsub(/[^0-9A-Za-z\s\-\_]/, '')     # remove special characters from string
                .gsub(/-/, '_')                     # replace dashes with underscore
                .gsub(/\s+/, '_')                   # replace spaces or spaces with single dash

            self.status = "normal" if self.status.blank?
            self.priority = "normal" if self.priority.blank?

            self.reference_module_bucket = "#{self.bucket.reference_module}-#{self.bucket.name}"

        end


        def path
            self[:engine_name]
            .downcase
            .sub("cloud", "")
            .concat(".")
            .concat(self[:bucket_name])
            .concat(".")
            .concat(self[:label])
        end

    end
end

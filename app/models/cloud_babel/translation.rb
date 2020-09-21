module CloudBabel
    class Translation < ApplicationRecord

        def self.stats

            # total translations registered in babel
            total_strings = Translation::String.all.count

            # total translations by language
            total_strings_translations = []
            
            Rails.application.config.lesli_settings["configuration"]["locales_available"].each do |locale|
                total_strings_translations.push({
                    code: locale[0],
                    name: locale[1],
                    total: Translation::String.where("#{locale[0]} is not null").where("#{locale[0]} != ''").count
                })
            end

            # total translations that needs help
            total_strings_waiting_for_help = Translation::String.where(:need_help => true).count

            # total translations that needs translation
            total_strings_waiting_for_translation = Translation::String.where(:need_translation => true).count
            
            {
                total_strings: total_strings,
                total_strings_translations: total_strings_translations,
                total_strings_waiting_for_help: total_strings_waiting_for_help,
                total_strings_waiting_for_translation: total_strings_waiting_for_translation,
                last_synchronization_at: LC::Date.to_string_datetime(Translation.first.updated_at)
            }

        end

        def self.search current_user, query, params
            
            search_string = params[:search_string]
            search_string = search_string.downcase
            search_string = search_string.gsub(" ","%")

            sql_where_condition = []

            # add filter to select only available languages 
            Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|
                sql_where_condition.push("LOWER(#{locale}) like :search_string")
            end

            sql_where_condition.push("LOWER(label) like :search_string")
            sql_where_condition.push("LOWER(context) like :search_string")

            strings = Translation::String.where(sql_where_condition.join(" OR "), { 
                search_string: "%#{search_string}%" 
            })

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

    end
end

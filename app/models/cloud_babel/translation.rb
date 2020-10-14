module CloudBabel
    class Translation < ApplicationRecord

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

            strings = String.where(sql_where_condition.join(" OR "), { 
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

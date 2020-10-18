module CloudBabel
    class Translation < ApplicationRecord

        def self.search current_user, query, params
            
            search_string = params[:search_string].downcase.gsub(" ","%")

            sql_where_condition = []

            # add filter to select only available languages 
            Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|
                sql_where_condition.push("LOWER(#{locale}) like :search_string")
            end

            sql_where_condition.push("LOWER(label) like :search_string")
            sql_where_condition.push("LOWER(context) like :search_string")

            # get strings with bucket and module information
            strings = String
            .joins("inner join cloud_babel_buckets on cloud_babel_buckets.id = cloud_babel_strings.cloud_babel_buckets_id")
            .joins("inner join cloud_babel_modules on cloud_babel_modules.id = cloud_babel_buckets.cloud_babel_modules_id")
            .where(sql_where_condition.join(" OR "), { search_string: "%#{search_string}%" })

            strings = strings.select(
                :id,
                :label,
                :status,
                :context,
                :priority,
                :need_help,
                :need_translation,
                Rails.application.config.lesli_settings["configuration"]["locales"],
                "cloud_babel_modules.id as engine_id",
                "cloud_babel_buckets.id as bucket_id",
                "cloud_babel_buckets.name as bucket_name",
                "cloud_babel_modules.name as engine_name",
                "cloud_babel_modules.platform as platform",
                "'' as path"
            )

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

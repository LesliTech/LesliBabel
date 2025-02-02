module LesliBabel
    class String < ApplicationRecord
        belongs_to :bucket

        before_create :clean_label_string
=begin
        enum prefix: {
            # database
            # controllers 
            # models
            # views
            # components
            # elements

            column
            enum

            message

            navigation
            toolbar

            button 
            chart
            title
            form
        }
=end

        def self.index(current_user, query, params)

            strings = TranslationsService.strings(params[:module], params[:bucket])

            # if search string was sent
            if params[:search]
                # search = "%#{params[:search].downcase.strip.gsub(' ', '%')}%"
              
                # # Dynamically build the `OR` conditions
                # sql_conditions = []
                # sql_values = { search: search }
              
                # Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|
                #     sql_conditions << "LOWER(#{locale}) LIKE :search"
                # end
              
                # sql_conditions << "LOWER(label) LIKE :search"
                # sql_conditions << "LOWER(context) LIKE :search"
              
                # # Use Active Record's `where` with a single parameterized query
                # strings = strings.where(sql_conditions.join(" OR "), sql_values)
            end

            # filters by specif ids sent as query params
            if params["ids"]
                ids = params["ids"].split(',').map{ |id| id.to_i }
                strings = strings.where("cloud_babel_strings.id in (?)", ids)
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

        end


        def self.relevant current_user, query, params
            # relevant strings:
            #   - missing translation for available language
            #   - need help
            #   - need translation

            locale = query.dig(:order, :by)
            strings = []
            sql_where_condition = []

            # add filter to select if is available language
            if locale
                if Rails.application.config.lesli.dig(:configuration, :locales).include?(locale.to_s)
                    sql_where_condition.push("#{locale.to_s} is NULL")
                    sql_where_condition.push("#{locale.to_s} = ''")
                end
            else
                Rails.application.config.lesli.dig(:configuration, :locales).each do |locale|
                    sql_where_condition.push("#{locale} is NULL")
                    sql_where_condition.push("#{locale} = ''")
                end
            end

            sql_where_condition.push("need_help = TRUE")
            sql_where_condition.push("need_translation = TRUE")

            strings = TranslationsService.strings.where(sql_where_condition.join(" OR ")).select(
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

            strings
            .page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
            .order(query.dig(:order, :by))

        end


        
        #######################################################################################
        ##############################  Activities Log Methods   ##############################
        #######################################################################################

        # @return [void]
        # @param current_user [::User] The user that created the string
        # @param [CloudBabel::String] The string that was created
        # @description Creates an activity for this string indicating who created it. And 
        #   also creates an activity with the initial status of the string
        # Example
        #   params = {...}
        #   string = CloudBabel::String.create(params)
        #   CloudBabel::String.log_activity_create(User.find(1), string)
        def self.log_activity_create(current_user, string)
            string.activities.create(
                user_creator: current_user,
                category: "action_create",
                reference_module_bucket_string: "#{string.reference_module_bucket}-#{string.label}"
            )
        end

        # @return [void]
        # @param current_user [::User] The user that created the string
        # @param string [CloudBabel::String] The string that was created
        # @param old_attributes[Hash] The data of the record before update
        # @param new_attributes[Hash] The data of the record after update
        # @description Creates an activity for this string if someone changed any of this values
        # Example
        #   string = CloudBabel::String.find(1)
        #   old_attributes  = string.attributes.merge({detail_attributes: string.detail.attributes})
        #   string.update(user_main: User.find(33))
        #   new_attributes = string.attributes.merge({detail_attributes: string.detail.attributes})
        #   CloudBabel::String.log_activity_update(User.find(1), string, old_attributes, new_attributes)
        def self.log_activity_update(current_user, string, old_attributes, new_attributes)
            # Bucket is a special case because it's a foreign key
            if old_attributes["cloud_babel_buckets_id"] != new_attributes["cloud_babel_buckets_id"]
                string.activities.create(
                    user_creator: current_user,
                    category: "action_update",
                    field_name: "cloud_babel_buckets_id",
                    value_from: Bucket.find(old_attributes["cloud_babel_buckets_id"]).name,
                    value_to:   Bucket.find(new_attributes["cloud_babel_buckets_id"]).name
                )
            end

            # We exclude certain keys that are not relevant
            old_attributes.except!("id", "cloud_babe_buckets_id", "created_at", "updated_at", "deleted_at", "users_id")

            old_attributes.each do |key, value|
                if value != new_attributes[key]
                    value_from = value
                    value_to = new_attributes[key]
                    value_from = LC::Date.to_string_datetime(value_from) if value_from.is_a?(Time) || value_from.is_a?(Date)
                    value_to = LC::Date.to_string_datetime(value_to) if value_to.is_a?(Time) || value_to.is_a?(Date)

                    string.activities.create(
                        user_creator: current_user,
                        category: "action_update",
                        field_name: key,
                        value_from: value_from,
                        value_to: value_to,
                        reference_module_bucket_string: "#{string.reference_module_bucket}-#{string.label}"
                    )
                end
            end
        end

        # @return [void]
        # @param current_user [::User] The user that created the string
        # @param [CloudBabel::String] The string that was created
        # @description Creates an activity for this string indicating that someone deleted it
        # Example
        #   string = CloudBabel::String.find(1)
        #   CloudBabel::String.log_activity_show(User.find(1), string)
        def self.log_activity_destroy(current_user, string)
            string.activities.create(
                user_creator: current_user,
                category: "action_destroy",
                reference_module_bucket_string: "#{string.reference_module_bucket}-#{string.label}"
            )
        end

        def path
            self[:engine_code]
            .downcase
            .concat(".")
            .concat(self[:bucket_code])
            .concat(".")
            .concat(self[:label])
        end

        private

        def clean_label_string

            self.label = self.label
                .downcase                           # string to lowercase
                .gsub(/[^0-9A-Za-z\s\-\_]/, '')     # remove special characters from string
                .gsub(/-/, '_')                     # replace dashes with underscore
                .gsub(/\s+/, '_')                   # replace spaces or spaces with single dash

            #self.status = "normal" if self.status.blank?
            self.reference_bucket = "#{self.bucket.reference_module}-#{self.bucket.code}"
        end
    end
end

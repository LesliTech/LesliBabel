require_dependency "cloud_babel/application_controller"

module CloudBabel
    class Translation::StringsController < ApplicationController
        before_action :set_translation_string, only: [:show, :edit, :update, :destroy, :need_help, :need_translation]

        # GET /translation/strings
        def index
            respond_to do |format|
                format.html { }
                format.json { 

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

                        sql_where_condition.push("help_needed = TRUE")
                        sql_where_condition.push("help_translation = TRUE")

                        strings = Translation::String.where(sql_where_condition.join(" OR ")).select(
                            :id,
                            :label,
                            :status,
                            :context,
                            :priority,
                            :help_needed,
                            :help_translation,
                            Rails.application.config.lesli_settings["configuration"]["locales"]
                        )

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

                    count = strings.length

                    strings = strings
                    .page(@query[:pagination][:page])
                    .per(@query[:pagination][:perPage])
                    .order("created_at DESC") 

                    respond_with_successful(LC::Response.pagination(
                        strings.current_page,
                        strings.total_pages,
                        strings.total_count,
                        strings.length,
                        strings
                    ))

                }
            end
        end

        # GET /translation/strings/1
        def show
        end

        # GET /translation/strings/new
        def new
            @translation_string = Translation::String.new
        end

        # GET /translation/strings/1/edit
        def edit
        end

        # POST /translation/strings
        def create

            translation_string = Translation::String.new(translation_string_params)
            translation_string.reference_bucket = "#{translation_string.bucket.module.name}-#{translation_string.bucket.name}"
            translation_string.user = current_user

            translation_string.last_update_status = Time.now
            translation_string.last_update_context = Time.now
            translation_string.last_update_priority = Time.now
            Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|
                translation_string["last_update_#{locale}"] = Time.now
            end
            
            if translation_string.save
                respond_with_successful(translation_string)
            else
                respond_with_error("Error on create translation string", translation_string.errors)
            end

        end

        # PATCH/PUT /translation/strings/1
        def update
            return respond_with_not_found unless @translation_string

            # if status changed
            if @translation_string["status"] != translation_string_params["status"]

                # saved update date
                @translation_string["last_update_status"] = Time.now

            end

            # if context changed
            if @translation_string["context"] != translation_string_params["context"]

                # saved update date
                @translation_string["last_update_context"] = Time.now

            end

            Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|
                # if translation changed
                if @translation_string[locale] != translation_string_params[locale]

                    # saved update date
                    @translation_string["last_update_#{locale}"] = Time.now

                end

            end

            if @translation_string.update(translation_string_params)
                @translation_string.update_attribute(:help_needed, false)
                respond_with_successful(@translation_string)
            else
                respond_with_error("Error on update translation string", @translation_object_group_section_label.errors)
            end

        end

        # DELETE /translation/strings/1
        def destroy
            return respond_with_not_found unless @translation_string
            
            @translation_string.deleted_at = Time.now
            @translation_string.save!
            respond_with_successful()
        end

        def need_help
            @translation_string.need_help = true
            @translation_string.save!
            respond_with_successful()
        end

        def need_translation
            @translation_string.need_translation = true
            @translation_string.save!
            respond_with_successful()
        end

        private

        # @return [void]
        # @description Sets the requested translation string based on the current_users's account
        # @example
        #     # Executing this method from a controller action:
        #     set_translation_string
        #     puts @translation_string
        #     # This will either display nil or an instance of Translation::String
        def set_translation_string
            @translation_string = Translation::String.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_string_params
            params.require(:translation_string).permit(
                :id,
                :label,
                :status,
                :context,
                :priority,
                :help_needed,
                :help_translation,
                :cloud_babel_translation_buckets_id,
                Rails.application.config.lesli_settings["configuration"]["locales"]
            )
        end

    end
end

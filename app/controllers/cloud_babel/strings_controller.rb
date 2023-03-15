require_dependency "cloud_babel/application_controller"

module CloudBabel
    class StringsController < ApplicationController
        before_action :set_string, only: [:show, :edit, :update, :destroy, :need_help, :need_translation]

        # GET /strings
        def index
            respond_to do |format|
                format.html { }
                format.json { 
                    respond_with_pagination(String.index(current_user, @query, params))
                }
            end
        end

        # GET /strings/1
        def show
        end

        # GET /strings/new
        def new
            @string = String.new
        end

        # GET /strings/1/edit
        def edit
        end

        # POST /strings
        def create

            if String.find_by(label: string_params[:label],cloud_babel_buckets_id: string_params[:cloud_babel_buckets_id])
                return respond_with_error("Duplicated string")
            end

            string = String.new(string_params)
            if string.save
                String.log_activity_create(current_user, string)
                respond_with_successful(string)
            else
                respond_with_error("Error on create translation string", string.errors)
            end
        end

        # PATCH/PUT /strings/1
        def update
            return respond_with_not_found unless @string

            # We store the original attributes
            old_attributes = @string.attributes

            # if status changed
            if @string["status"] != string_params["status"]

                # saved update date
                @string["last_update_status"] = Time.now

            end

            # if context changed
            if @string["context"] != string_params["context"]

                # saved update date
                @string["last_update_context"] = Time.now

            end

            Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|

                # if translation changed
                if @string[locale] != string_params[locale]

                    # saved update date
                    @string["last_update_#{locale}"] = Time.now

                end

            end

            if @string.update(string_params)

                # We store the new attributes and compare the activities
                new_attributes = @string.attributes
                String.log_activity_update(current_user, @string, old_attributes, new_attributes)

                respond_with_successful(@string)
            else
                respond_with_error(@string.errors.full_sentence)
            end

        end

        # DELETE /strings/1
        def destroy
            return respond_with_not_found unless @string

            if @string.destroy
                respond_with_successful

                String.log_activity_destroy(current_user, @string)
            else
                respond_with_error(@string.errors.full_messages.to_sentence)
            end
        end

        def stats
            respond_with_successful(String.stats)
        end

        def relevant
            respond_with_pagination(String.relevant(current_user, @query, params))
        end

        # return a list of the locales available
        def locales
            respond_with_successful(Rails.application.config.lesli.dig(:configuration, :locales))
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_string
            @string = String.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def string_params
            params.require(:string).permit(
                :id,
                :label,
                :status,
                :context,
                :priority,
                :need_help,
                :need_translation,
                :cloud_babel_buckets_id,
                Rails.application.config.lesli_settings["configuration"]["locales"]
            )
        end

    end
end

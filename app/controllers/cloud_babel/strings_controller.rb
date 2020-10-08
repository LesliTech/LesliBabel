require_dependency "cloud_babel/application_controller"

module CloudBabel
    class StringsController < ApplicationController
        before_action :set_string, only: [:show, :edit, :update, :destroy]

        # GET /strings
        def index
            respond_to do |format|
                format.html { }
                format.json { 
                    respond_with_successful(String.index(current_user, @query, params))
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
            translation_string = String.new(string_params)
            #translation_string.reference_bucket = "#{translation_string.bucket.module.name}-#{translation_string.bucket.name}"
            #translation_string.user = current_user

            #translation_string.last_update_status = Time.now
            #translation_string.last_update_context = Time.now
            #translation_string.last_update_priority = Time.now
            Rails.application.config.lesli_settings["configuration"]["locales"].each do |locale|
                #translation_string["last_update_#{locale}"] = Time.now
            end
            
            if translation_string.save
                respond_with_successful(translation_string)
            else
                respond_with_error("Error on create translation string", translation_string.errors)
            end
        end

        # PATCH/PUT /strings/1
        def update

            return respond_with_not_found unless @string

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
                @string.update_attribute(:need_help, false)
                respond_with_successful(@string)
            else
                respond_with_error(@string.errors.full_sentence)
            end

        end

        # DELETE /strings/1
        def destroy
            @string.destroy
            redirect_to strings_url, notice: 'String was successfully destroyed.'
        end

        def stats
            respond_with_successful(String.stats)
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

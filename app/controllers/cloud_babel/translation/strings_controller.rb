require_dependency "cloud_babel/application_controller"

module CloudBabel
    class Translation::StringsController < ApplicationController
        before_action :set_translation_string, only: [:show, :edit, :update, :destroy]

        # GET /translation/strings
        def index
            respond_to do |format|
                format.html { }
                format.json { 

                    # empty strings by default
                    strings = []

                    # if bucket or module was not sent, return all the strings in the database
                    if params[:module_id].blank? and params[:bucket_id].blank?
                        strings = Translation::String.all
                    end

                    # returns strings for specif module
                    if not params[:module_id].blank? and params[:bucket_id].blank?
                        strings = Translation::String
                            .joins(:bucket)
                            .where("cloud_babel_translation_buckets.cloud_babel_translation_modules_id = ?", params[:module_id])
                    end

                    # returns strings for specif module and bucket
                    if not params[:module_id].blank? and not params[:bucket_id].blank?
                        bucket = Translation::Bucket.find(params[:bucket_id])
                        strings = bucket.strings
                    end

                    strings = strings.map do |string|
                        {
                            id: string.id,
                            path: "#{string.bucket.module.name.downcase}.#{string.bucket.name.downcase}.#{string.label.downcase}",
                            context: string.context,
                            label: string.label,
                            es: string.es,
                            en: string.en,
                            de: string.de,
                            fr: string.fr,
                            status: string.status
                        }
                    end
                    responseWithSuccessful(strings) 
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
            
            if translation_string.save
                responseWithSuccessful(translation_string)
            else
                responseWithError("Error on create translation string", translation_string.errors)
            end
        end

        # PATCH/PUT /translation/strings/1
        def update
            if @translation_string.update(translation_string_params)
                responseWithSuccessful(@translation_string)
            else
                responseWithError("Error on update translation string", @translation_object_group_section_label.errors)
            end
        end

        # DELETE /translation/strings/1
        def destroy
            @translation_string.destroy
            redirect_to translation_strings_url, notice: 'String was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_translation_string
            @translation_string = Translation::String.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_string_params
            params.require(:translation_string).permit(:context, :label, :en, :es, :de, :status, :cloud_babel_translation_buckets_id)
        end

    end
end

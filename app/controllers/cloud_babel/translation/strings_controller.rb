require_dependency "cloud_babel/application_controller"

module CloudBabel
    class Translation::StringsController < ApplicationController
        before_action :set_translation_string, only: [:show, :edit, :update, :destroy]

        # GET /translation/strings
        def index
            bucket = Translation::Bucket.find(params[:bucket_id])
            respond_to do |format|
                format.html { }
                format.json { responseWithSuccessful(bucket.strings) }
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

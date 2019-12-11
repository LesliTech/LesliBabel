require_dependency "cloud_babel/application_controller"

module CloudBabel
    class TranslationsController < ApplicationController
        before_action :set_translation, only: [:show, :edit, :update, :destroy]

        # GET /translations
        def index
            respond_to do |format|
                format.html { }
                format.json { responseWithSuccessful(Translation.all) }
            end
        end

        # GET /translations/1
        def show
        end

        # GET /translations/new
        def new
            @translation = Translation.new
        end

        # GET /translations/1/edit
        def edit
        end

        # POST /translations
        def create
            @translation = Translation.new(translation_params)

            if @translation.save
                responseWithSuccessful(@translation)
            else
                responseWithError("Error creating translation", @translation.errors.full_messages)
            end
        end

        # PATCH/PUT /translations/1
        def update
            if @translation.update(translation_params)
                responseWithSuccessful(@translation)
            else
                render :edit
            end
        end

        # DELETE /translations/1
        def destroy
            @translation.destroy
            redirect_to translations_url, notice: 'Translation was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_translation
            @translation = Translation.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_params
            params.require(:translation).permit(
                :module_name,
                :class_name
            )
        end

    end
end

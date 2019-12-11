require_dependency "cloud_babel/application_controller"

module CloudBabel
  class TranslationObjectStringsController < ApplicationController
    before_action :set_translation_object_string, only: [:show, :edit, :update, :destroy]

    # GET /translation_object_strings
    def index
        respond_to do |format|
            format.html { }
            format.json { responseWithSuccessful(TranslationObjectString.all) }
        end
    end

    # GET /translation_object_strings/1
    def show
    end

    # GET /translation_object_strings/new
    def new
      @translation_object_string = TranslationObjectString.new
    end

    # GET /translation_object_strings/1/edit
    def edit
    end

    # POST /translation_object_strings
    def create
      @translation_object_string = TranslationObjectString.new(translation_object_string_params)

      if @translation_object_string.save
        responseWithSuccessful(@translation_object_string)
    else
      responseWithError("Error creating translation object string", @translation_object_string.errors.full_messages)
      end
    end

    # PATCH/PUT /translation_object_strings/1
    def update
      if @translation_object_string.update(translation_object_string_params)
        responseWithSuccessful(@translation_object_string)
      else
        render :edit
      end
    end

    # DELETE /translation_object_strings/1
    def destroy
      @translation_object_string.destroy
      redirect_to translation_object_strings_url, notice: 'Translation object string was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_translation_object_string
        @translation_object_string = TranslationObjectString.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def translation_object_string_params
        params.require(:translation_object_string).permit(
            :label,
            :es,
            :en,
            :de,
            :fr,
            :cloud_babel_translation_objects_id
        )
      end
  end
end

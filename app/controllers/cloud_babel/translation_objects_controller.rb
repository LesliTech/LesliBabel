require_dependency "cloud_babel/application_controller"

module CloudBabel
  class TranslationObjectsController < ApplicationController
    before_action :set_translation_object, only: [:show, :edit, :update, :destroy]

    # GET /translation_objects
    def index
        translation_objects = TranslationObject.where(cloud_babel_translations_id: params[:translation_id])
        respond_to do |format|
            format.html { }
            format.json { responseWithSuccessful(translation_objects) }
        end
    end

    # GET /translation_objects/1
    def show
    end

    # GET /translation_objects/new
    def new
      @translation_object = TranslationObject.new
    end

    # GET /translation_objects/1/edit
    def edit
    end

    # POST /translation_objects
    def create
      @translation_object = TranslationObject.new(translation_object_params)
 
      if @translation_object.save!
        responseWithSuccessful(@translation_object)
      else
        responseWithError("Error creating translation object", @translation_object.errors.full_messages)
      end
    end

    # PATCH/PUT /translation_objects/1
    def update
      if @translation_object.update(translation_object_params)
        responseWithSuccessful(@translation_object)
      else
        render :edit
      end
    end

    # DELETE /translation_objects/1
    def destroy
      @translation_object.destroy
      redirect_to translation_objects_url, notice: 'Translation object was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_translation_object
        @translation_object = TranslationObject.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def translation_object_params
        params.require(:translation_object).permit(
            :method,
            :section,
            :object_type,
            :cloud_babel_translations_id
        )
      end
  end
end

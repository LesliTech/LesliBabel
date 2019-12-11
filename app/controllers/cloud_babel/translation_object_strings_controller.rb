require_dependency "cloud_babel/application_controller"

module CloudBabel
  class TranslationObjectStringsController < ApplicationController
    before_action :set_translation_object_string, only: [:show, :edit, :update, :destroy]

    # GET /translation_object_strings
    def index
      @translation_object_strings = TranslationObjectString.all
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
        redirect_to @translation_object_string, notice: 'Translation object string was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /translation_object_strings/1
    def update
      if @translation_object_string.update(translation_object_string_params)
        redirect_to @translation_object_string, notice: 'Translation object string was successfully updated.'
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
        params.fetch(:translation_object_string, {})
      end
  end
end

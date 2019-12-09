require_dependency "cloud_babel/application_controller"

module CloudBabel
  class Translation::ObjectStringsController < ApplicationController
    before_action :set_translation_object_string, only: [:show, :edit, :update, :destroy]

    # GET /translation/object_strings
    def index
      @translation_object_strings = Translation::ObjectString.all
    end

    # GET /translation/object_strings/1
    def show
    end

    # GET /translation/object_strings/new
    def new
      @translation_object_string = Translation::ObjectString.new
    end

    # GET /translation/object_strings/1/edit
    def edit
    end

    # POST /translation/object_strings
    def create
      @translation_object_string = Translation::ObjectString.new(translation_object_string_params)

      if @translation_object_string.save
        redirect_to @translation_object_string, notice: 'Object string was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /translation/object_strings/1
    def update
      if @translation_object_string.update(translation_object_string_params)
        redirect_to @translation_object_string, notice: 'Object string was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /translation/object_strings/1
    def destroy
      @translation_object_string.destroy
      redirect_to translation_object_strings_url, notice: 'Object string was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_translation_object_string
        @translation_object_string = Translation::ObjectString.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def translation_object_string_params
        params.fetch(:translation_object_string, {})
      end
  end
end

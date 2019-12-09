require_dependency "cloud_babel/application_controller"

module CloudBabel
  class Translation::ObjectsController < ApplicationController
    before_action :set_translation_object, only: [:show, :edit, :update, :destroy]

    # GET /translation/objects
    def index
      @translation_objects = Translation::Object.all
    end

    # GET /translation/objects/1
    def show
    end

    # GET /translation/objects/new
    def new
      @translation_object = Translation::Object.new
    end

    # GET /translation/objects/1/edit
    def edit
    end

    # POST /translation/objects
    def create
      @translation_object = Translation::Object.new(translation_object_params)

      if @translation_object.save
        redirect_to @translation_object, notice: 'Object was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /translation/objects/1
    def update
      if @translation_object.update(translation_object_params)
        redirect_to @translation_object, notice: 'Object was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /translation/objects/1
    def destroy
      @translation_object.destroy
      redirect_to translation_objects_url, notice: 'Object was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_translation_object
        @translation_object = Translation::Object.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def translation_object_params
        params.fetch(:translation_object, {})
      end
  end
end

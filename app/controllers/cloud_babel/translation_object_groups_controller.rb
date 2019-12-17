require_dependency "cloud_babel/application_controller"

module CloudBabel
  class TranslationObjectGroupsController < ApplicationController
    before_action :set_translation_object_group, only: [:show, :edit, :update, :destroy]

    # GET /translation_object_groups
    def index
      @translation_object_groups = TranslationObjectGroup.all
    end

    # GET /translation_object_groups/1
    def show
    end

    # GET /translation_object_groups/new
    def new
      @translation_object_group = TranslationObjectGroup.new
    end

    # GET /translation_object_groups/1/edit
    def edit
    end

    # POST /translation_object_groups
    def create
      @translation_object_group = TranslationObjectGroup.new(translation_object_group_params)

      if @translation_object_group.save
        redirect_to @translation_object_group, notice: 'Translation object group was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /translation_object_groups/1
    def update
      if @translation_object_group.update(translation_object_group_params)
        redirect_to @translation_object_group, notice: 'Translation object group was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /translation_object_groups/1
    def destroy
      @translation_object_group.destroy
      redirect_to translation_object_groups_url, notice: 'Translation object group was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_translation_object_group
        @translation_object_group = TranslationObjectGroup.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def translation_object_group_params
        params.fetch(:translation_object_group, {})
      end
  end
end

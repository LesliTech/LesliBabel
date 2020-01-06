require_dependency "cloud_babel/application_controller"

module CloudBabel
  class TranslationObjectGroupSectionsController < ApplicationController
    before_action :set_translation_object_group_section, only: [:show, :edit, :update, :destroy]

    # GET /translation_object_group_sections
    def index
        respond_to do |format|
            format.html { }
            format.json {  responseWithSuccessful(
                Translation.find(params[:translation_id])
                .objects.find(params[:translation_object_id])
                .groups.find(params[:translation_object_group_id])
                .sections
            )}
        end
    end

    # GET /translation_object_group_sections/1
    def show
    end

    # GET /translation_object_group_sections/new
    def new
      @translation_object_group_section = TranslationObjectGroupSection.new
    end

    # GET /translation_object_group_sections/1/edit
    def edit
    end

    # POST /translation_object_group_sections
    def create
      @translation_object_group_section = TranslationObjectGroupSection.new(translation_object_group_section_params)

      if @translation_object_group_section.save
        redirect_to @translation_object_group_section, notice: 'Translation object group section was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /translation_object_group_sections/1
    def update
      if @translation_object_group_section.update(translation_object_group_section_params)
        redirect_to @translation_object_group_section, notice: 'Translation object group section was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /translation_object_group_sections/1
    def destroy
      @translation_object_group_section.destroy
      redirect_to translation_object_group_sections_url, notice: 'Translation object group section was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_translation_object_group_section
        @translation_object_group_section = TranslationObjectGroupSection.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def translation_object_group_section_params
        params.fetch(:translation_object_group_section, {})
      end
  end
end

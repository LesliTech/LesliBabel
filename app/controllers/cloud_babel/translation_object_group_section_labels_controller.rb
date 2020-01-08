require_dependency "cloud_babel/application_controller"

module CloudBabel
    class TranslationObjectGroupSectionLabelsController < ApplicationController
        before_action :set_translation_object_group_section_label, only: [:show, :edit, :update, :destroy]

        # GET /translation_object_group_section_labels
        def index
            #@translation_object_group_section_labels = TranslationObjectGroupSectionLabel.all
            respond_to do |format|
                format.html { }
                format.json {  

                    translation = Translation.find(params[:translation_id])

                    responseWithSuccessful(translation.labels.where("cloud_babel_translation_object_group_sections_id is null")) if params[:translation_object_id].blank?

                    unless params[:translation_object_id].blank?
                        responseWithSuccessful(
                            translation
                            .objects.find(params[:translation_object_id])
                            .groups.find(params[:translation_object_group_id])
                            .sections.find(params[:translation_object_group_section_id])
                            .labels
                        )
                    end

=begin                    
                    responseWithSuccessful(
                        Translation
                        .find(params[:translation_id])
                        .objects.find(params[:translation_object_id])
                        .groups.find(params[:translation_object_group_id])
                        .sections.find(params[:translation_object_group_section_id])
                        .labels
                    )
=end
                }
            end
        end

        # GET /translation_object_group_section_labels/1
        def show
        end

        # GET /translation_object_group_section_labels/new
        def new
            @translation_object_group_section_label = TranslationObjectGroupSectionLabel.new
        end

        # GET /translation_object_group_section_labels/1/edit
        def edit
        end

        # POST /translation_object_group_section_labels
        def create
            translation_object_group_section_label = TranslationObjectGroupSectionLabel.new(translation_object_group_section_label_params)
            translation_object_group_section_label.user = current_user
            if translation_object_group_section_label.save
                responseWithSuccessful(translation_object_group_section_label)
            else
                responseWithError(translation_object_group_section_label.errors.full_messages)
            end
        end

        # PATCH/PUT /translation_object_group_section_labels/1
        def update
            @translation_object_group_section_label.user = current_user
            if @translation_object_group_section_label.update(translation_object_group_section_label_params)
                responseWithSuccessful(@translation_object_group_section_label)
            else
                responseWithError("Error creating translation object", @translation_object_group_section_label.errors.full_messages)
            end
        end

        # DELETE /translation_object_group_section_labels/1
        def destroy
            @translation_object_group_section_label.destroy
            redirect_to translation_object_group_section_labels_url, notice: 'Translation object group section label was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_translation_object_group_section_label
            @translation_object_group_section_label = TranslationObjectGroupSectionLabel.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_object_group_section_label_params
            
            params.require(:translation_object_group_section_label).permit(:context, :label, :en, :es, :de, :cloud_babel_translations_id, :cloud_babel_translation_object_group_sections_id)
        end
    end
end

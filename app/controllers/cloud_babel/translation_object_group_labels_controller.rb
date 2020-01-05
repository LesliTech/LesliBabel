require_dependency "cloud_babel/application_controller"

module CloudBabel
    class TranslationObjectGroupLabelsController < ApplicationController
        before_action :set_translation_object_group_label, only: [:show, :edit, :update, :destroy]

        # GET /translation_object_group_labels
        def index
            respond_to do |format|
                format.html { }
                format.json {  
                    responseWithSuccessful(
                        Translation
                        .find(params[:translation_id])
                        .objects.find(params[:translation_object_id])
                        .groups.find(params[:translation_object_group_id])
                        .labels
                    )
                }
            end
        end

        # GET /translation_object_group_labels/1
        def show
        end

        # GET /translation_object_group_labels/new
        def new
            @translation_object_group_label = TranslationObjectGroupLabel.new
        end

        # GET /translation_object_group_labels/1/edit
        def edit
        end

        # POST /translation_object_group_labels
        def create
            translation_object_group_label = TranslationObjectGroupLabel.new(translation_object_group_label_params)
            translation_object_group_label.user = current_user
            if translation_object_group_label.save
                responseWithSuccessful(translation_object_group_label)
            else
                responseWithError(translation_object_group_label.errors.full_messages)
            end
        end

        # PATCH/PUT /translation_object_group_labels/1
        def update
            @translation_object_group_label.user = current_user
            if @translation_object_group_label.update(translation_object_group_label_params)
                responseWithSuccessful(@translation_object_group_label)
            else
                responseWithError("Error creating translation object", @translation_object_group_label.errors.full_messages)
            end
        end

        # DELETE /translation_object_group_labels/1
        def destroy
            @translation_object_group_label.destroy
            redirect_to translation_object_group_labels_url, notice: 'Translation object group label was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_translation_object_group_label
            @translation_object_group_label = TranslationObjectGroupLabel.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_object_group_label_params
            params.require(:translation_object_group_label).permit(:context, :label, :en, :es, :de, :cloud_babel_translation_object_groups_id)
        end

    end
end
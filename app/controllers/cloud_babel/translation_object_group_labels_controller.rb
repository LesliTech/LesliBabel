require_dependency "cloud_babel/application_controller"

module CloudBabel
  class TranslationObjectGroupLabelsController < ApplicationController
    before_action :set_translation_object_group_label, only: [:show, :edit, :update, :destroy]

    # GET /translation_object_group_labels
    def index
      @translation_object_group_labels = TranslationObjectGroupLabel.all
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
      @translation_object_group_label = TranslationObjectGroupLabel.new(translation_object_group_label_params)

      if @translation_object_group_label.save
        redirect_to @translation_object_group_label, notice: 'Translation object group label was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /translation_object_group_labels/1
    def update
      if @translation_object_group_label.update(translation_object_group_label_params)
        redirect_to @translation_object_group_label, notice: 'Translation object group label was successfully updated.'
      else
        render :edit
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
        params.fetch(:translation_object_group_label, {})
      end
  end
end

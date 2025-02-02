module LesliBabel
    class LabelsController < ApplicationController
        before_action :set_label, only: %i[ show edit update destroy ]
        before_action :set_module, only: [:new]

        # GET /labels
        def index
            @labels = respond_as_pagination(LabelService.new(current_user, query).index(params))
        end

        # GET /labels/1
        def show
            @label = @label.show
        end

        # GET /labels/new
        def new
            @label = Label.new
        end

        # POST /labels
        def create
            @label = Label.new(label_params)
            if @label.save
                redirect_to label_path(@label.id), notice: "Label was successfully created."
            else
                render :new, status: :unprocessable_entity
            end
        end

        # PATCH/PUT /labels/1
        def update
            if @label.update(label_params)
                redirect_to @label, notice: "Label was successfully updated.", status: :see_other
            else
                render :edit, status: :unprocessable_entity
            end
        end

        # DELETE /labels/1
        def destroy
            @label.destroy
            redirect_to labels_url, notice: "Label was successfully destroyed.", status: :see_other
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_label
            @label = LabelService.new(current_user, query).find(params[:id])
        end

        def set_module 
            modules_id = params.dig(:modules_id)
            modules_id = @label.result.bucket.module if @label
            @module = ModuleService.new(current_user, query).find(modules_id).result
        end

        # Only allow a list of trusted parameters through.
        def label_params
            params.require(:label).permit(
                :id,
                :text,
                :status,
                :context,
                :bucket_id,
                Lesli.config.locales.keys
            )
        end
    end
end

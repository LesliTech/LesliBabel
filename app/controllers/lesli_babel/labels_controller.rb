module LesliBabel
    class LabelsController < ApplicationController
        before_action :set_label, only: %i[ show edit update destroy ]
        before_action :set_module, only: [:new]

        # GET /labels
        def index
            query[:pagination][:perPage] = 100
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
                success("Label was successfully created.")
                respond_to do |format|
                    format.turbo_stream
                    format.html { redirect_to @label.id }
                end
            else
                render :new, status: :unprocessable_entity
            end
        end

        # PATCH/PUT /labels/1
        def update
            return respond_with_not_found unless @label.found?

            #@label = Label.find_by_id(@label.result.id)
            @label = @label.result

            # We store the original attributes
            old_attributes = @label.attributes

            # if status changed
            if @label["status"] != label_params["status"]

                # saved update date
                @label["last_update_status"] = Time.now

            end

            # if context changed
            if @label["context"] != label_params["context"]

                # saved update date
                @label["last_update_context"] = Time.now

            end

            Lesli.config.locales.keys.each do |locale|

                # if translation changed
                if @label[locale] != label_params[locale]

                    # saved update date
                    @label["last_update_#{locale}"] = Time.now
                end
            end

            if @label.update(label_params)

                # We store the new attributes and compare the activities
                new_attributes = @label.attributes
                #String.log_activity_update(current_user, @string, old_attributes, new_attributes)

                success("Translation updated successfully!")
                respond_to do |format|
                    format.turbo_stream
                    format.html { redirect_to @label.id }
                end
            else
                redirect_to label_path(@label.id), notice: "Error"
            end

            # if @label.update(label_params)
            #     redirect_to @label, notice: "Label was successfully updated.", status: :see_other
            # else
            #     render :edit, status: :unprocessable_entity
            # end
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
                :prefix,
                :status,
                :context,
                :bucket_id,
                Lesli.config.locales.keys
            )
        end
    end
end

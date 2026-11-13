module LesliBabel
    class LabelsController < ApplicationController
        before_action :set_label, only: %i[show edit update destroy ]
        before_action :set_module, only: [:new]

        # GET /labels
        def index
            query[:pagination][:perPage] = 100
            @labels = respond_with_pagination(LabelService.new(current_user, query).index(params))
            if params[:missing].to_s == "true"
                @missing_translations = true
                @missing_locale = configured_locale_name(params[:locale])
            end
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
                respond_to do |format|
                    format.html 
                    format.turbo_stream do 
                        respond_with_lesli(
                            :turbo => [
                                stream_notification_success('Label was successfully created.'),
                                stream_redirection(label_path(@label))
                            ]
                        )
                    end
                end
            else
                render :new, status: :unprocessable_entity
            end
        end

        def edit
        end

        # PATCH/PUT /labels/1
        def update
            return respond_with_not_found unless @label.found?

            @label = @label.result
            @module = @label.bucket.module

            # if status changed
            if @label["status"] != label_params["status"]

                # saved update date
                @label["last_update_status"] = Time.current

            end

            # if context changed
            if @label["context"] != label_params["context"]

                # saved update date
                @label["last_update_context"] = Time.current

            end

            babel_locales.each_key do |locale|

                # if translation changed
                if @label[locale] != label_params[locale]

                    # saved update date
                    @label["last_update_#{locale}"] = Time.current
                end
            end

            if @label.update(label_params)
                respond_with_lesli(
                    :turbo => [
                        stream_notification_success("Translation label updated successfully!"),
                        turbo_stream.replace('lesli-babel-labels-form', partial: 'lesli_babel/labels/form')
                    ]
                )
            else
                message = @label.errors.full_messages.to_sentence.presence || "Translation label could not be updated."

                respond_with_lesli(
                    turbo: [
                        stream_notification_danger(message),
                        turbo_stream.replace('lesli-babel-labels-form', partial: 'lesli_babel/labels/form')
                    ],
                    json: { errors: @label.errors.to_hash },
                    html: :show,
                    status: :unprocessable_content
                )
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

        def configured_locale_name(locale)
            Lesli.config.babel.fetch(:locales).each do |code, name|
                return name if code.to_s == locale.to_s
            end

            nil
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
                babel_locales.keys
            )
        end
    end
end

module LesliBabel
    class LabelsController < ApplicationController
        before_action :set_label, only: %i[show update destroy]
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
            render(:panel, layout: false) if turbo_frame_request?
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

        # PATCH/PUT /labels/1
        def update
            return respond_with_not_found unless @label.found?

            @label = @label.result
            @module = @label.bucket.module
            attributes = label_params

            update_change_timestamps(@label, attributes)

            if @label.update(attributes)
                respond_with_lesli(
                    :turbo => [
                        stream_notification_success("Translations saved successfully."),
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
            return respond_with_not_found unless @label.found?

            label = @label.result
            module_id = label.bucket.module_id
            label.destroy!

            redirect_back(
                fallback_location: labels_path(modules_id: module_id),
                notice: "Translation was permanently deleted.",
                status: :see_other
            )
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
            babel_locales.find { |code, _name| code.to_s == locale.to_s }&.last
        end

        def update_change_timestamps(label, attributes)
            changed_at = Time.current

            tracked_attributes.each do |attribute|
                next unless attributes.key?(attribute)
                next if label[attribute] == attributes[attribute]

                label["last_update_#{attribute}"] = changed_at
            end
        end

        def tracked_attributes
            %w[status context] + babel_locale_codes.map(&:to_s)
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
                babel_locale_codes
            )
        end
    end
end

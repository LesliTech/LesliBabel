require "test_helper"

module LesliBabel
    class LabelsControllerTest < ActionController::TestCase
        tests LesliBabel::LabelsController

        setup do
            @routes = LesliBabel::Engine.routes
            @original_locales = Lesli.config.babel[:locales]
            Lesli.config.babel[:locales] = { en: "English", es: "Español" }

            @translation_module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_engine")
            @bucket = LesliBabel::Bucket.create!(
                code: "labels",
                reference_module: "lesli_babel",
                module: @translation_module
            )
            @label = LesliBabel::Label.create!(
                bucket: @bucket,
                text: "page_title",
                status: :ok,
                en: "Labels",
                es: "Traducciones",
                fr: "Traductions"
            )

            @controller.define_singleton_method(:authenticate_request) { true }
            @controller.define_singleton_method(:authorize_request) { true }
            @controller.define_singleton_method(:log_requests) { true }
            @controller.define_singleton_method(:current_user) { nil }
        end

        teardown do
            Lesli.config.babel[:locales] = @original_locales
        end

        test "does not expose an edit action without a route" do
            assert_not_includes LesliBabel::LabelsController.action_methods, "edit"
        end

        test "updates only locales configured in Babel" do
            patch :update, params: {
                id: @label.id,
                label: {
                    status: "ok",
                    context: "Navigation title",
                    en: "Translation labels: %{count} :records",
                    es: "Etiquetas de traducción",
                    fr: "Texte remplacé"
                }
            }, format: :turbo_stream

            assert_response :success
            @label.reload
            assert_equal "Translation labels: %{count} :records", @label.en
            assert_equal "Etiquetas de traducción", @label.es
            assert_equal "Traductions", @label.fr
            assert_not_nil @label.last_update_en
            assert_not_nil @label.last_update_es
            assert_not_nil @label.last_update_context
            assert_nil @label.last_update_status
            assert_nil @label.last_update_fr
            assert_includes response.body, "Translations saved successfully."
        end

        test "does not change the editorial status when translations are saved" do
            @label.update!(status: :need_help, es: "")

            patch :update, params: {
                id: @label.id,
                label: {
                    context: "Navigation title",
                    en: "Labels",
                    es: "Traducciones"
                }
            }, format: :turbo_stream

            assert_response :success
            @label.reload
            assert_equal "need_help", @label.status
            assert_equal "Traducciones", @label.es
            assert_nil @label.last_update_status
        end

        test "renders the editor inside the requested panel frame" do
            @request.headers["Turbo-Frame"] = "babel-label-editor"

            get :show, params: { id: @label.id }

            assert_response :success
            assert_select "turbo-frame#babel-label-editor", count: 1
            assert_select "#lesli-babel-labels-form", count: 1
            assert_select "h3", text: "Page Title"
            assert_select "code", count: 0
        end

        test "renders the real validation error in the notification and form" do
            @label.errors.add(:base, "Translation could not be saved")
            @label.define_singleton_method(:update) do |attributes|
                assign_attributes(attributes)
                false
            end

            with_label_service(@label) do
                patch :update, params: {
                    id: @label.id,
                    label: {
                        status: "ok",
                        context: "Unsaved context",
                        en: "Unsaved English",
                        es: "Traducción sin guardar"
                    }
                }, format: :turbo_stream
            end

            assert_response :unprocessable_content
            assert_includes response.body, "Translation could not be saved"
            assert_not_includes response.body, "Translations saved successfully."
            assert_includes response.body, "Unsaved English"
            assert_includes response.body, "Traducción sin guardar"
            assert_includes response.body, "Unsaved context"
            assert_select "turbo-stream[action='replace'][target='lesli-babel-labels-form']"
            assert_select "[role='alert']", text: /Translation could not be saved/
        end

        test "permanently deletes a label and returns to the original list" do
            return_url = @routes.url_helpers.labels_url(
                host: "test.host",
                missing: "true",
                locale: "es"
            )
            @request.headers["HTTP_REFERER"] = return_url

            assert_difference("LesliBabel::Label.count", -1) do
                delete :destroy, params: { id: @label.id }
            end

            assert_redirected_to return_url
            assert_equal "Translation was permanently deleted.", flash[:notice]
        end

        private

        def with_label_service(label)
            service = Object.new
            service.define_singleton_method(:find) { |_id| self }
            service.define_singleton_method(:found?) { true }
            service.define_singleton_method(:result) { label }

            singleton_class = LabelService.singleton_class
            original_new = singleton_class.instance_method(:new)
            singleton_class.define_method(:new) { |*_arguments| service }

            yield
        ensure
            singleton_class.define_method(:new, original_new)
        end
    end
end

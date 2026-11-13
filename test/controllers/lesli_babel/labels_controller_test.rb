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

        test "updates only locales configured in Babel" do
            patch :update, params: {
                id: @label.id,
                label: {
                    status: "ok",
                    context: "Navigation title",
                    en: "Translation labels",
                    es: "Etiquetas de traducción",
                    fr: "Texte remplacé"
                }
            }, format: :turbo_stream

            assert_response :success
            @label.reload
            assert_equal "Translation labels", @label.en
            assert_equal "Etiquetas de traducción", @label.es
            assert_equal "Traductions", @label.fr
        end

        test "renders the real validation error in the notification and form" do
            @label.errors.add(:base, "Translation could not be saved")
            @label.define_singleton_method(:update) { |_attributes| false }

            with_label_service(@label) do
                patch :update, params: {
                    id: @label.id,
                    label: { status: "ok", context: "", en: "Labels", es: "Traducciones" }
                }, format: :turbo_stream
            end

            assert_response :unprocessable_content
            assert_includes response.body, "Translation could not be saved"
            assert_select "turbo-stream[action='replace'][target='lesli-babel-labels-form']"
            assert_select "[role='alert']", text: /Translation could not be saved/
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

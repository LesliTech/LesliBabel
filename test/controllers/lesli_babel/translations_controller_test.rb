require "test_helper"

module LesliBabel
    class TranslationsControllerTest < ActionController::TestCase
        tests LesliBabel::TranslationsController

        setup do
            @routes = LesliBabel::Engine.routes
            @allow_web_deploy = Lesli.config.babel[:allow_web_deploy]
            Lesli.config.babel[:allow_web_deploy] = true

            @controller.define_singleton_method(:authenticate_request) { true }
            @controller.define_singleton_method(:authorize_request) { true }
            @controller.define_singleton_method(:log_requests) { true }
        end

        teardown do
            Lesli.config.babel[:allow_web_deploy] = @allow_web_deploy
        end

        test "deploys through the new service before returning success" do
            calls = 0
            deploy = lambda do
                calls += 1
                {
                    files: ["/engines/LesliBabel/config/locales/translations.en.yml"],
                    errors: []
                }
            end

            with_deploy_service(deploy) do
                post :deploy, format: :json
            end

            assert_response :success
            assert_equal 1, calls
            assert_equal "Translations deployed successfully.", response.parsed_body["message"]
            assert_equal ["/engines/LesliBabel/config/locales/translations.en.yml"], response.parsed_body["files"]
        end

        test "shows the success notification in the web interface" do
            deploy = -> { { files: ["translations.en.yml"], errors: [] } }

            with_deploy_service(deploy) do
                post :deploy, format: :turbo_stream
            end

            assert_response :success
            assert_includes response.body, "Translations deployed successfully."
        end

        test "returns every generation error without reporting success" do
            deploy = lambda do
                {
                    files: [],
                    errors: [
                        "LesliSupport/en: module not found",
                        "LesliSupport/es: module not found"
                    ]
                }
            end

            with_deploy_service(deploy) do
                post :deploy, format: :json
            end

            assert_response :unprocessable_content
            assert_equal "LesliSupport/en: module not found; LesliSupport/es: module not found",
                response.parsed_body["message"]
            assert_equal 2, response.parsed_body["errors"].size
        end

        test "returns the real filesystem error" do
            deploy = -> { raise Errno::EACCES, "/engines/LesliBabel/config/locales" }

            with_deploy_service(deploy) do
                post :deploy, format: :json
            end

            assert_response :unprocessable_content
            assert_includes response.parsed_body["message"], "Permission denied"
            assert_includes response.parsed_body["message"], "/engines/LesliBabel/config/locales"
        end

        test "does not invoke the service when web deploy is disabled" do
            Lesli.config.babel[:allow_web_deploy] = false
            calls = 0
            deploy = -> { calls += 1 }

            with_deploy_service(deploy) do
                post :deploy, format: :json
            end

            assert_response :forbidden
            assert_equal 0, calls
            assert_equal "Web translation deploy is disabled.", response.parsed_body["message"]
        end

        test "does not expose actions backed by retired services" do
            assert_not_respond_to @controller, :sync
            assert_not_respond_to @controller, :renovate
            assert_not_respond_to @controller, :download
        end

        private

        def with_deploy_service(deploy)
            singleton_class = TranslationDeployService.singleton_class
            original_call = singleton_class.instance_method(:call)
            replacement = -> { deploy.call }
            singleton_class.define_method(:call, replacement)

            yield
        ensure
            singleton_class.define_method(:call, original_call)
        end
    end
end

require "test_helper"
require "rake"

Rails.application.load_tasks unless Rake::Task.task_defined?("lesli_babel:deploy")

module LesliBabel
    class TranslationDeployTaskTest < ActiveSupport::TestCase
        setup do
            @task = Rake::Task["lesli_babel:deploy"]
            @task.reenable
            @engines = {
                "Lesli" => engine("Lesli", "lesli"),
                "LesliBabel" => engine("LesliBabel", "lesli_babel")
            }
        end

        teardown do
            @task.reenable
        end

        test "invokes the deploy service and reports every updated file" do
            calls = 0
            messages = []
            files = @engines.values.map do |engine|
                File.join(engine[:dir], "config/locales/translations.en.yml")
            end
            deploy = lambda do
                calls += 1
                { files: files, errors: [] }
            end

            run_task(deploy: deploy, messages: messages)

            assert_equal 1, calls
            deployed = messages.select { |message| message[:text] == "Translations deployed" }
            assert_equal 2, deployed.size
            assert_equal ["Lesli", "LesliBabel"], deployed.pluck(:data).pluck(:engine)
            assert deployed.all? { |message| message[:data][:file] == "translations.en.yml" }
            assert_equal "Translation deploy completed", messages.last[:text]
        end

        test "finishes with an error when a document cannot be generated" do
            messages = []
            listed_errors = []
            deploy = -> { { files: [], errors: ["LesliSupport/en: module not found"] } }

            error = assert_raises(RuntimeError) do
                run_task(deploy: deploy, messages: messages, listed_errors: listed_errors)
            end

            assert_equal "Translation deploy failed", error.message
            assert_equal ["LesliSupport/en: module not found"], listed_errors
            assert_equal "Translation deploy failed", messages.last[:text]
            assert_not messages.any? { |message| message[:text] == "Translations deployed" }
        end

        test "propagates filesystem errors from the deploy service" do
            deploy = -> { raise Errno::EIO, "write failed" }

            assert_raises(Errno::EIO) do
                run_task(deploy: deploy)
            end
        end

        private

        def engine(name, code)
            {
                name: name,
                code: code,
                dir: "/engines/#{code}"
            }
        end

        def run_task(deploy:, messages: [], listed_errors: [])
            engines = @engines
            deploy_call = -> { deploy.call }
            success = ->(text, **data) { messages << { type: :success, text: text, data: data } }
            danger = ->(text, **data) { messages << { type: :danger, text: text, data: data } }
            list = ->(*errors, **_options) { listed_errors.concat(errors) }

            with_singleton_methods(LesliSystem, engines: -> { engines }) do
                with_singleton_methods(TranslationDeployService, call: deploy_call) do
                    with_singleton_methods(Termline, success: success, danger: danger, list: list) do
                        @task.reenable
                        @task.invoke
                    end
                end
            end
        end

        def with_singleton_methods(target, replacements)
            singleton_class = target.singleton_class
            originals = replacements.to_h do |method_name, _implementation|
                [method_name, singleton_class.instance_method(method_name)]
            end

            replacements.each do |method_name, implementation|
                singleton_class.define_method(method_name, implementation)
            end

            yield
        ensure
            originals.each do |method_name, original_method|
                singleton_class.define_method(method_name, original_method)
            end
        end
    end
end

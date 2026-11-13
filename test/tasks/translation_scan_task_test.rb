require "test_helper"
require "rake"

Rails.application.load_tasks unless Rake::Task.task_defined?("lesli_babel:scan")

module LesliBabel
    class TranslationScanTaskTest < ActiveSupport::TestCase
        setup do
            @task = Rake::Task["lesli_babel:scan"]
            @task.reenable
        end

        teardown do
            @task.reenable
        end

        test "registers the host application and Lesli core with their official identities" do
            resources = {
                "rails_app" => routes("users/invitations"),
                "lesli" => routes("dashboards"),
                "lesli_babel" => routes("labels")
            }

            run_task(resources)

            assert LesliBabel::Module.exists?(code: "main_app", platform: "rails_app")
            assert LesliBabel::Module.exists?(code: "lesli", platform: "lesli_core")
            assert LesliBabel::Module.exists?(code: "lesli_babel", platform: "lesli_engine")
            assert_not LesliBabel::Module.exists?(code: "rails_app")
        end

        private

        def routes(route)
            { route.class.name => { route: route } }
        end

        def run_task(resources)
            resource_service = Object.new
            resource_service.define_singleton_method(:index) do |matrix:|
                raise ArgumentError unless matrix

                resources
            end

            with_singleton_methods(Lesli::ResourceService, new: -> { resource_service }) do
                with_singleton_methods(Termline, success: ->(*_messages, **_data) {}) do
                    @task.reenable
                    @task.invoke
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

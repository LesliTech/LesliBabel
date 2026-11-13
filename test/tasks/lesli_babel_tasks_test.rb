require "test_helper"
require "rake"

Rails.application.load_tasks unless Rake::Task.task_defined?("lesli_babel:import")

module LesliBabel
    class TasksTest < ActiveSupport::TestCase
        setup do
            @task = Rake::Task["lesli_babel:import"]
            @task.reenable
        end

        teardown do
            @task.reenable
        end

        test "discovers translation files from every engine" do
            engines = {
                "Lesli" => engine(code: "lesli", name: "Lesli", dir: "/engines/Lesli"),
                "LesliSupport" => engine(code: "lesli_support", name: "LesliSupport", dir: "/engines/LesliSupport")
            }
            files = {
                translation_pattern("/engines/Lesli") => [
                    "/engines/Lesli/config/locales/translations.en.yml"
                ],
                translation_pattern("/engines/LesliSupport") => [
                    "/engines/LesliSupport/config/locales/translations.en.yml",
                    "/engines/LesliSupport/config/locales/translations.es.yml"
                ]
            }
            calls = []
            result = import_result

            run_task(engines: engines, files: files) do |file_path:, platform:|
                calls << { file_path: file_path, platform: platform }
                result
            end

            assert_equal files.values.flatten.sort, calls.pluck(:file_path).sort
        end

        test "sends the platform that corresponds to each engine" do
            engines = {
                "Root" => engine(code: "root", name: "Root", dir: "/application"),
                "Lesli" => engine(code: "lesli", name: "Lesli", dir: "/engines/Lesli"),
                "LesliBabel" => engine(code: "lesli_babel", name: "LesliBabel", dir: "/engines/LesliBabel")
            }
            files = engines.values.to_h do |engine_info|
                path = File.join(engine_info[:dir], "config", "locales", "translations.en.yml")
                [translation_pattern(engine_info[:dir]), [path]]
            end
            calls = []
            result = import_result

            run_task(engines: engines, files: files) do |file_path:, platform:|
                calls << { file_path: file_path, platform: platform }
                result
            end

            platforms = calls.to_h { |call| [call[:file_path], call[:platform]] }
            assert_equal "rails_app", platforms["/application/config/locales/translations.en.yml"]
            assert_equal "lesli_core", platforms["/engines/Lesli/config/locales/translations.en.yml"]
            assert_equal "lesli_engine", platforms["/engines/LesliBabel/config/locales/translations.en.yml"]
        end

        test "invokes the import service once per file" do
            engines = {
                "LesliBabel" => engine(code: "lesli_babel", name: "LesliBabel", dir: "/engines/LesliBabel")
            }
            file_paths = %w[en es fr].map do |locale|
                "/engines/LesliBabel/config/locales/translations.#{locale}.yml"
            end
            files = { translation_pattern("/engines/LesliBabel") => file_paths }
            calls = []
            result = import_result

            run_task(engines: engines, files: files) do |file_path:, platform:|
                calls << { file_path: file_path, platform: platform }
                result
            end

            assert_equal 3, calls.size
            assert_equal file_paths.sort, calls.pluck(:file_path).sort
            assert_equal 3, calls.pluck(:file_path).uniq.size
        end

        test "accumulates file results in the final summary" do
            engines = {
                "LesliBabel" => engine(code: "lesli_babel", name: "LesliBabel", dir: "/engines/LesliBabel")
            }
            first_file = "/engines/LesliBabel/config/locales/translations.en.yml"
            second_file = "/engines/LesliBabel/config/locales/translations.es.yml"
            files = { translation_pattern("/engines/LesliBabel") => [first_file, second_file] }
            results = {
                first_file => import_result(
                    modules: 1,
                    buckets: 2,
                    labels: 3,
                    completed: 4,
                    skipped: 5,
                    errors: ["first error"]
                ),
                second_file => import_result(
                    modules: 2,
                    buckets: 3,
                    labels: 4,
                    completed: 5,
                    skipped: 6,
                    errors: ["second error", "third error"]
                )
            }
            danger_calls = []
            list_calls = []
            service_calls = []

            error = assert_raises(TranslationImportService::InvalidStructureError) do
                run_task(
                    engines: engines,
                    files: files,
                    termline: {
                        danger: ->(*messages, **data) { danger_calls << { messages: messages, data: data } },
                        list: ->(*items, **_options) { list_calls.concat(items) }
                    }
                ) do |file_path:, platform:|
                    service_calls << { file_path: file_path, platform: platform }
                    results.fetch(file_path)
                end
            end

            assert_equal "Translation import rejected 3 invalid entries", error.message
            assert_equal ["lesli_engine"], service_calls.pluck(:platform).uniq
            assert_equal ["first error", "second error", "third error"], list_calls
            assert_equal 1, danger_calls.size
            assert_equal(
                {
                    files_processed: 2,
                    modules_created: 3,
                    buckets_created: 5,
                    labels_created: 7,
                    translations_completed: 9,
                    translations_skipped: 11,
                    structural_errors: 3
                },
                danger_calls.first[:data]
            )
        end

        private

        def engine(code:, name:, dir:)
            { code: code, name: name, dir: dir }
        end

        def translation_pattern(directory)
            File.join(directory, "config", "locales", "translations.*.yml")
        end

        def import_result(modules: 0, buckets: 0, labels: 0, completed: 0, skipped: 0, errors: [])
            {
                created: {
                    modules: modules,
                    buckets: buckets,
                    labels: labels
                },
                completed: completed,
                skipped: skipped,
                errors: errors
            }
        end

        def run_task(engines:, files:, termline: {}, &service_call)
            termline_methods = {
                info: ->(*_messages, **_data) {},
                success: ->(*_messages, **_data) {},
                warning: ->(*_messages, **_data) {},
                danger: ->(*_messages, **_data) {},
                list: ->(*_items, **_options) {}
            }.merge(termline)

            with_singleton_methods(LesliSystem, engines: -> { engines }) do
                with_singleton_methods(Dir, :[] => ->(pattern) { files.fetch(pattern, []) }) do
                    with_singleton_methods(TranslationImportService, call: service_call) do
                        with_singleton_methods(Termline, termline_methods) do
                            @task.reenable
                            @task.invoke
                        end
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

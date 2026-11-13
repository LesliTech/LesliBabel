require "test_helper"
require "rake"
require "tmpdir"

Rails.application.load_tasks unless Rake::Task.task_defined?("lesli_babel:export")

module LesliBabel
    class TranslationExportTaskTest < ActiveSupport::TestCase
        setup do
            @task = Rake::Task["lesli_babel:export"]
            @task.reenable
            @workspace = Dir.mktmpdir("lesli-babel-export-task")
            @original_locales = Lesli.config.babel[:locales]
            Lesli.config.babel[:locales] = { en: "English", es: "Español" }
        end

        teardown do
            @task.reenable
            Lesli.config.babel[:locales] = @original_locales
            FileUtils.remove_entry(@workspace)
        end

        test "exports every engine and locale to the requested directory" do
            output_dir = File.join(@workspace, "output")
            engines = {
                "Root" => engine("Root", "root"),
                "Lesli" => engine("Lesli", "lesli"),
                "LesliBabel" => engine("LesliBabel", "lesli_babel")
            }
            calls = []
            messages = []

            run_task(output_dir, engines: engines, messages: messages) do |engine:, platform:, locale:|
                calls << { engine: engine, platform: platform, locale: locale }
                export_result(engine, locale)
            end

            assert_equal 6, calls.size
            assert_equal ["main_app"], calls.select { |call| call[:platform] == "rails_app" }.pluck(:engine).pluck(:code).uniq
            assert_equal ["lesli"], calls.select { |call| call[:platform] == "lesli_core" }.pluck(:engine).pluck(:code).uniq
            assert_equal ["lesli_babel"], calls.select { |call| call[:platform] == "lesli_engine" }.pluck(:engine).pluck(:code).uniq

            engines.values.each do |engine|
                %w[en es].each do |locale|
                    exported_file = File.join(output_dir, engine[:code], "translations.#{locale}.yml")
                    assert File.exist?(exported_file)
                end
            end

            file_messages = messages.select { |message| message[:text] == "Translations exported" }
            assert_equal 6, file_messages.size
            assert file_messages.all? { |message| message[:data].keys == [:engine, :file] }
        end

        test "uses a temporary directory when no output directory is provided" do
            temporary_output = File.join(@workspace, "temporary-output")
            engines = { "LesliBabel" => engine("LesliBabel", "lesli_babel") }
            messages = []
            prefixes = []
            mktmpdir = lambda do |prefix|
                prefixes << prefix
                FileUtils.mkdir_p(temporary_output)
                temporary_output
            end

            with_singleton_methods(Dir, mktmpdir: mktmpdir) do
                run_task(nil, engines: engines, messages: messages) do |engine:, platform:, locale:|
                    export_result(engine, locale)
                end
            end

            assert File.exist?(File.join(temporary_output, "lesli_babel/translations.en.yml"))
            assert_equal ["lesli-babel-export"], prefixes
            completed = messages.find { |message| message[:text] == "Translation export completed" }
            assert_equal temporary_output, completed[:data][:directory]
        end

        test "does not write any files when document generation fails" do
            output_dir = File.join(@workspace, "output")
            engines = { "LesliBabel" => engine("LesliBabel", "lesli_babel") }
            calls = 0

            assert_raises(ActiveRecord::RecordNotFound) do
                run_task(output_dir, engines: engines) do |engine:, platform:, locale:|
                    calls += 1
                    raise ActiveRecord::RecordNotFound if locale == "es"

                    export_result(engine, locale)
                end
            end

            assert_equal 2, calls
            assert_not Dir.exist?(output_dir)
        end

        test "never writes to the official paths returned by the exporter" do
            output_dir = File.join(@workspace, "output")
            engines = { "LesliBabel" => engine("LesliBabel", "lesli_babel") }

            run_task(output_dir, engines: engines) do |engine:, platform:, locale:|
                export_result(engine, locale)
            end

            official_files = Dir[File.join(engines["LesliBabel"][:dir], "config/locales/translations.*.yml")]
            assert_empty official_files
            assert File.exist?(File.join(output_dir, "lesli_babel/translations.en.yml"))
        end

        private

        def engine(name, code)
            {
                name: name,
                code: code,
                dir: File.join(@workspace, "installed", name)
            }
        end

        def export_result(engine, locale)
            {
                file_path: File.join(engine[:dir], "config/locales/translations.#{locale}.yml"),
                content: "---\n#{locale}: {}\n"
            }
        end

        def run_task(output_dir, engines:, messages: [], &export_call)
            success = lambda do |text, **data|
                messages << { text: text, data: data }
            end
            export = ->(**arguments) { export_call.call(**arguments) }

            with_singleton_methods(LesliSystem, engines: -> { engines }) do
                with_singleton_methods(TranslationExportService, call: export) do
                    with_singleton_methods(Termline, success: success) do
                        @task.reenable
                        output_dir ? @task.invoke(output_dir) : @task.invoke
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

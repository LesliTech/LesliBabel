require "test_helper"
require "tmpdir"

module LesliBabel
    class TranslationDeployServiceTest < ActiveSupport::TestCase
        setup do
            @workspace = Dir.mktmpdir("lesli-babel-deploy")
            @original_locales = Lesli.config.babel[:locales]
            Lesli.config.babel[:locales] = { en: "English", es: "Español" }

            @core_engine = engine("Lesli", "lesli")
            @babel_engine = engine("LesliBabel", "lesli_babel")

            create_translation_module("lesli", "lesli_core", "Core")
            create_translation_module("lesli_babel", "lesli_engine", "Babel")
        end

        teardown do
            Lesli.config.babel[:locales] = @original_locales
            FileUtils.remove_entry(@workspace)
        end

        test "deploys every engine and locale to its official path" do
            result = deploy_with_engines("Lesli" => @core_engine, "LesliBabel" => @babel_engine)

            expected_files = [@core_engine, @babel_engine].flat_map do |engine|
                %w[en es].map do |locale|
                    File.join(engine[:dir], "config/locales/translations.#{locale}.yml")
                end
            end

            assert_empty result[:errors]
            assert_equal expected_files.sort, result[:files].sort
            expected_files.each { |file_path| assert File.exist?(file_path) }

            babel_document = YAML.safe_load(
                File.read(File.join(@babel_engine[:dir], "config/locales/translations.en.yml"))
            )
            assert_equal "Babel", babel_document.dig("en", "lesli_babel", "labels", "title")
        end

        test "produces identical content when deployed more than once" do
            engines = { "Lesli" => @core_engine, "LesliBabel" => @babel_engine }
            first_deploy = deploy_with_engines(engines)
            first_content = first_deploy[:files].to_h { |file_path| [file_path, File.binread(file_path)] }

            second_deploy = deploy_with_engines(engines)
            second_content = second_deploy[:files].to_h { |file_path| [file_path, File.binread(file_path)] }

            assert_empty second_deploy[:errors]
            assert_equal first_content, second_content
        end

        test "maps root to the main app module and rails app platform" do
            root_engine = engine("Root", "root")
            create_translation_module("main_app", "rails_app", "Application")

            result = deploy_with_engines("Root" => root_engine)
            document = YAML.safe_load(File.read(result[:files].first))

            assert_equal ["main_app"], document.fetch("en").keys
            assert_equal "Application", document.dig("en", "main_app", "labels", "title")
        end

        test "generates every document before replacing destinations" do
            events = []
            original_export = TranslationExportService.method(:call)
            original_rename = File.method(:rename)

            export_call = lambda do |**arguments|
                events << [:export, arguments[:engine][:name], arguments[:locale].to_s]
                original_export.call(**arguments)
            end
            rename_call = lambda do |source, destination|
                events << [:rename, File.basename(destination)]
                original_rename.call(source, destination)
            end

            with_singleton_methods(TranslationExportService, call: export_call) do
                with_singleton_methods(File, rename: rename_call) do
                    deploy_with_engines("Lesli" => @core_engine, "LesliBabel" => @babel_engine)
                end
            end

            first_rename = events.index { |event| event.first == :rename }
            assert_equal 4, events.take(first_rename).count { |event| event.first == :export }
        end

        test "uses temporary files beside destinations before atomic rename" do
            renames = []
            original_rename = File.method(:rename)
            rename_call = lambda do |source, destination|
                renames << [source, destination, File.exist?(source)]
                original_rename.call(source, destination)
            end

            with_singleton_methods(File, rename: rename_call) do
                deploy_with_engines("LesliBabel" => @babel_engine)
            end

            assert_equal 2, renames.size
            renames.each do |source, destination, source_existed|
                assert source_existed
                assert_equal File.dirname(destination), File.dirname(source)
                assert_match(/\.tmp\z/, source)
            end
        end

        test "checks every destination before replacing existing files" do
            first_path = locale_path(@babel_engine, "en")
            second_path = locale_path(@babel_engine, "es")
            File.write(first_path, "original en")
            File.write(second_path, "original es")
            original_writable = File.method(:writable?)

            writable = lambda do |path|
                path == second_path ? false : original_writable.call(path)
            end

            assert_raises(Errno::EACCES) do
                with_singleton_methods(File, writable?: writable) do
                    deploy_with_engines("LesliBabel" => @babel_engine)
                end
            end

            assert_equal "original en", File.read(first_path)
            assert_equal "original es", File.read(second_path)
        end

        test "propagates rename errors and removes remaining temporary files" do
            first_path = locale_path(@babel_engine, "en")
            second_path = locale_path(@babel_engine, "es")
            File.binwrite(first_path, "original en")
            File.binwrite(second_path, "original es")
            rename = ->(_source, _destination) { raise Errno::EIO, "rename failed" }

            assert_raises(Errno::EIO) do
                with_singleton_methods(File, rename: rename) do
                    deploy_with_engines("LesliBabel" => @babel_engine)
                end
            end

            assert_equal "original en", File.binread(first_path)
            assert_equal "original es", File.binread(second_path)
            temporary_files = Dir[File.join(@babel_engine[:dir], "config/locales/.*.tmp")]
            assert_empty temporary_files
        end

        test "returns useful errors and writes nothing when a module is missing" do
            missing_engine = engine("LesliSupport", "lesli_support")

            result = deploy_with_engines("LesliBabel" => @babel_engine, "LesliSupport" => missing_engine)

            assert_empty result[:files]
            assert_equal 2, result[:errors].size
            assert result[:errors].all? { |error| error.start_with?("LesliSupport/") }
            assert_empty Dir[File.join(@babel_engine[:dir], "config/locales/translations.*.yml")]
        end

        private

        def engine(name, code)
            directory = File.join(@workspace, name)
            FileUtils.mkdir_p(File.join(directory, "config/locales"))

            {
                name: name,
                code: code,
                dir: directory
            }
        end

        def create_translation_module(code, platform, value)
            translation_module = LesliBabel::Module.create!(code: code, platform: platform)
            bucket = translation_module.buckets.create!(code: "labels", reference_module: code)
            bucket.labels.create!(text: "title", en: value, es: value)
        end

        def locale_path(engine, locale)
            File.join(engine[:dir], "config/locales/translations.#{locale}.yml")
        end

        def deploy_with_engines(engines)
            with_singleton_methods(LesliSystem, engines: -> { engines }) do
                TranslationDeployService.call
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

require "test_helper"
require "tmpdir"

module LesliBabel
    class TranslationExportServiceTest < ActiveSupport::TestCase
        setup do
            @engine_dir = Dir.mktmpdir("lesli-babel-export")
            @engine = {
                code: "lesli_babel",
                dir: @engine_dir
            }
            @translation_module = LesliBabel::Module.create!(
                code: "lesli_babel",
                platform: "lesli_engine"
            )
        end

        teardown do
            FileUtils.remove_entry(@engine_dir)
        end

        test "builds deterministic YAML with string keys without writing a file" do
            zeta_bucket = create_bucket("zeta")
            alpha_bucket = create_bucket("alpha")

            zeta_bucket.labels.create!(text: "title", en: "Zeta")
            alpha_bucket.labels.create!(text: "second", en: "Second")
            alpha_bucket.labels.create!(text: "first", en: "First")

            result = export
            document = YAML.safe_load(result[:content])

            assert_equal File.join(@engine_dir, "config/locales/translations.en.yml"), result[:file_path]
            assert_equal ["en"], document.keys
            assert_equal ["lesli_babel"], document.fetch("en").keys
            assert_equal ["alpha", "zeta"], document.dig("en", "lesli_babel").keys
            assert_equal ["first", "second"], document.dig("en", "lesli_babel", "alpha").keys
            assert_equal "First", document.dig("en", "lesli_babel", "alpha", "first")
            assert_not File.exist?(result[:file_path])
        end

        test "exports only the module matching code and platform" do
            core_module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_core")
            core_bucket = core_module.buckets.create!(code: "core", reference_module: "lesli_babel")
            core_bucket.labels.create!(text: "title", en: "Core")

            engine_bucket = create_bucket("engine")
            engine_bucket.labels.create!(text: "title", en: "Engine")

            document = YAML.safe_load(export[:content])

            assert_equal ["engine"], document.dig("en", "lesli_babel").keys
            assert_equal "Engine", document.dig("en", "lesli_babel", "engine", "title")
        end

        test "uses placeholders for blank values and excludes disabled labels" do
            bucket = create_bucket("labels")
            bucket.labels.create!(text: "message_missing", en: "")
            bucket.labels.create!(text: "message_disabled", status: :disabled, en: "Disabled")
            bucket.labels.create!(text: "message_enabled", status: :ok, en: "Enabled")

            document = YAML.safe_load(export[:content])
            labels = document.dig("en", "lesli_babel", "labels")

            assert_equal ":lesli_babel.labels.message_missing:", labels.fetch("message_missing")
            assert_equal "Enabled", labels.fetch("message_enabled")
            assert_not labels.key?("message_disabled")
        end

        test "preserves existing values and interpolation tokens without transformation" do
            bucket = create_bucket("labels")
            translation = "  Found %{count} results  "
            bucket.labels.create!(text: "message_results", en: translation)

            document = YAML.safe_load(export[:content])

            assert_equal translation, document.dig("en", "lesli_babel", "labels", "message_results")
        end

        test "does not persist generated placeholders in labels" do
            bucket = create_bucket("labels")
            label = bucket.labels.create!(text: "message_missing", en: "")
            original_updated_at = label.updated_at

            document = YAML.safe_load(export[:content])

            label.reload
            assert_equal ":lesli_babel.labels.message_missing:", document.dig("en", "lesli_babel", "labels", "message_missing")
            assert_equal "", label.en
            assert_nil label.last_update_en
            assert_equal original_updated_at, label.updated_at
        end

        test "normalizes symbol locales to string keys and filenames" do
            bucket = create_bucket("labels")
            bucket.labels.create!(text: "title", es: "Traducciones")

            result = TranslationExportService.call(
                engine: @engine,
                platform: "lesli_engine",
                locale: :es
            )
            document = YAML.safe_load(result[:content])

            assert_equal ["es"], document.keys
            assert_equal "translations.es.yml", File.basename(result[:file_path])
            assert_equal "Traducciones", document.dig("es", "lesli_babel", "labels", "title")
        end

        test "raises when the module does not exist for the platform" do
            error = assert_raises(ActiveRecord::RecordNotFound) do
                TranslationExportService.call(
                    engine: @engine,
                    platform: "rails_app",
                    locale: :en
                )
            end

            assert_equal "Translation module not found: code=lesli_babel, platform=rails_app", error.message
        end

        private

        def create_bucket(code)
            @translation_module.buckets.create!(
                code: code,
                reference_module: @translation_module.code
            )
        end

        def export
            TranslationExportService.call(
                engine: @engine,
                platform: "lesli_engine",
                locale: :en
            )
        end
    end
end

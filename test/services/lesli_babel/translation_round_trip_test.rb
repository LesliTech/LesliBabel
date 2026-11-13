require "test_helper"
require "tempfile"
require "tmpdir"

module LesliBabel
    class TranslationRoundTripTest < ActiveSupport::TestCase
        setup do
            @engine_dir = Dir.mktmpdir("lesli-babel-round-trip")
            @engine = {
                code: "round_trip",
                dir: @engine_dir
            }
        end

        teardown do
            FileUtils.remove_entry(@engine_dir)
        end

        test "preserves the YAML structure after export and import" do
            source_module = LesliBabel::Module.create!(
                code: "round_trip",
                platform: "lesli_core"
            )
            labels = source_module.buckets.create!(
                code: "labels",
                reference_module: "round_trip"
            ).labels
            labels.create!(text: "message_count", en: "Found %{count} results")
            labels.create!(text: "message_missing", en: "")
            labels.create!(text: "message_disabled", status: :disabled, en: "Disabled")

            original_export = TranslationExportService.call(
                engine: @engine,
                platform: "lesli_core",
                locale: :en
            )

            Tempfile.create(["translations.en", ".yml"]) do |yaml_file|
                yaml_file.binmode
                yaml_file.write(original_export[:content])
                yaml_file.flush

                result = TranslationImportService.call(
                    file_path: yaml_file.path,
                    platform: "lesli_engine"
                )

                assert_empty result[:errors]
            end

            imported_export = TranslationExportService.call(
                engine: @engine,
                platform: "lesli_engine",
                locale: :en
            )

            assert_equal YAML.safe_load(original_export[:content]),
                YAML.safe_load(imported_export[:content])
            assert_equal original_export[:content], imported_export[:content]
            assert_equal "Found %{count} results",
                YAML.safe_load(imported_export[:content]).dig(
                    "en",
                    "round_trip",
                    "labels",
                    "message_count"
                )
        end
    end
end

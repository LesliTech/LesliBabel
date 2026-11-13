require "test_helper"
require "tempfile"

module LesliBabel
    class TranslationImportServiceTest < ActiveSupport::TestCase
        setup do
            @yaml_file = Tempfile.new(["translations.en", ".yml"])
            @yaml_file.write("---\nen: {}\n")
            @yaml_file.close
        end

        teardown do
            @yaml_file.unlink
        end

        test "returns the import summary contract" do
            result = TranslationImportService.call(
                file_path: @yaml_file.path,
                platform: "lesli_engine"
            )

            assert_equal(
                {
                    created: {
                        modules: 0,
                        buckets: 0,
                        labels: 0
                    },
                    completed: 0,
                    skipped: 0,
                    errors: []
                },
                result
            )
        end

        test "requires a file path and platform" do
            assert_raises(ArgumentError) do
                TranslationImportService.call(file_path: @yaml_file.path)
            end

            assert_raises(ArgumentError) do
                TranslationImportService.call(platform: "lesli_engine")
            end
        end

        test "returns a new summary for every import" do
            first_result = TranslationImportService.call(
                file_path: @yaml_file.path,
                platform: "lesli_engine"
            )
            second_result = TranslationImportService.call(
                file_path: @yaml_file.path,
                platform: "lesli_engine"
            )

            refute_same first_result, second_result
            refute_same first_result[:created], second_result[:created]
            refute_same first_result[:errors], second_result[:errors]
        end

        test "propagates YAML parsing errors" do
            @yaml_file.open
            @yaml_file.truncate(0)
            @yaml_file.write("en: [\n")
            @yaml_file.close

            assert_raises(Psych::SyntaxError) do
                TranslationImportService.call(
                    file_path: @yaml_file.path,
                    platform: "lesli_engine"
                )
            end
        end

        test "propagates filesystem errors" do
            assert_raises(Errno::ENOENT) do
                TranslationImportService.call(
                    file_path: "#{@yaml_file.path}.missing",
                    platform: "lesli_engine"
                )
            end
        end
    end
end

require "test_helper"

module LesliBabel
    class TranslationImportServiceTest < ActiveSupport::TestCase
        test "returns the import summary contract" do
            result = TranslationImportService.call(
                file_path: "/tmp/translations.en.yml",
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
                TranslationImportService.call(file_path: "/tmp/translations.en.yml")
            end

            assert_raises(ArgumentError) do
                TranslationImportService.call(platform: "lesli_engine")
            end
        end

        test "returns a new summary for every import" do
            first_result = TranslationImportService.call(
                file_path: "/tmp/translations.en.yml",
                platform: "lesli_engine"
            )
            second_result = TranslationImportService.call(
                file_path: "/tmp/translations.en.yml",
                platform: "lesli_engine"
            )

            refute_same first_result, second_result
            refute_same first_result[:created], second_result[:created]
            refute_same first_result[:errors], second_result[:errors]
        end
    end
end

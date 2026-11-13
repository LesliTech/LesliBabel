require "test_helper"
require "tempfile"

module LesliBabel
    class TranslationImportServiceTest < ActiveSupport::TestCase
        setup do
            @yaml_file = Tempfile.new(["translations.en", ".yml"])
            @yaml_file.write(<<~YAML)
                ---
                en:
                  lesli_babel:
                    labels:
                      button_save: "Save"
            YAML
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
                        modules: 1,
                        buckets: 1,
                        labels: 1
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

        test "creates missing modules buckets and labels" do
            result = TranslationImportService.call(
                file_path: @yaml_file.path,
                platform: "lesli_engine"
            )

            translation_module = LesliBabel::Module.find_by!(
                code: "lesli_babel",
                platform: "lesli_engine"
            )
            bucket = translation_module.buckets.find_by!(code: "labels")
            label = bucket.labels.find_by!(text: "button_save")

            assert_equal "lesli_babel", bucket.reference_module
            assert_equal "lesli_babel-labels", label.reference_bucket
            assert_equal "Save", label.en
            assert_equal 1, result[:created][:modules]
            assert_equal 1, result[:created][:buckets]
            assert_equal 1, result[:created][:labels]
        end

        test "does not duplicate an existing hierarchy" do
            TranslationImportService.call(
                file_path: @yaml_file.path,
                platform: "lesli_engine"
            )

            result = TranslationImportService.call(
                file_path: @yaml_file.path,
                platform: "lesli_engine"
            )

            assert_equal 1, LesliBabel::Module.where(code: "lesli_babel", platform: "lesli_engine").count
            assert_equal 1, LesliBabel::Bucket.where(code: "labels").count
            assert_equal 1, LesliBabel::Label.where(text: "button_save").count
            assert_equal({ modules: 0, buckets: 0, labels: 0 }, result[:created])
        end

        test "rolls back the entire file when a record cannot be created" do
            write_yaml(<<~YAML)
                ---
                en:
                  transactional_module:
                    labels:
                      first_label: "First"
                unknown_locale:
                  transactional_module:
                    labels:
                      second_label: "Second"
            YAML

            assert_raises(ActiveModel::UnknownAttributeError) do
                TranslationImportService.call(
                    file_path: @yaml_file.path,
                    platform: "lesli_engine"
                )
            end

            assert_not LesliBabel::Module.exists?(code: "transactional_module", platform: "lesli_engine")
            assert_not LesliBabel::Bucket.exists?(code: "labels", reference_module: "transactional_module")
            assert_not LesliBabel::Label.exists?(text: "first_label")
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

        test "rejects invalid levels and includes their paths" do
            invalid_documents = {
                "---\n- en\n" => ["<root>", "locales"],
                "---\nen: invalid\n" => ["en", "modules"],
                "---\nen:\n  lesli_babel: invalid\n" => ["en.lesli_babel", "buckets"],
                "---\nen:\n  lesli_babel:\n    labels: invalid\n" => ["en.lesli_babel.labels", "labels"],
                "---\nen:\n  lesli_babel:\n    labels:\n      button_save:\n        nested: invalid\n" => ["en.lesli_babel.labels.button_save", "string"]
            }

            invalid_documents.each do |yaml, (path, expected)|
                write_yaml(yaml)

                error = assert_raises(TranslationImportService::InvalidStructureError) do
                    TranslationImportService.call(
                        file_path: @yaml_file.path,
                        platform: "lesli_engine"
                    )
                end

                assert_includes error.message, path
                assert_includes error.message, "expected #{expected}"
            end
        end

        private

        def write_yaml(yaml)
            @yaml_file.open
            @yaml_file.truncate(0)
            @yaml_file.write(yaml)
            @yaml_file.close
        end
    end
end

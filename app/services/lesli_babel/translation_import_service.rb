require "yaml"

module LesliBabel
    # Imports one YAML translation file into the Babel database.
    #
    # The expected hierarchy is locale -> module -> bucket -> label -> string.
    # Every call validates the complete document before opening a transaction.
    # Database writes for the file are atomic: if one record cannot be created,
    # none of the records created by that import are persisted.
    #
    # @example
    #   LesliBabel::TranslationImportService.call(
    #       file_path: "/path/to/translations.en.yml",
    #       platform: "lesli_engine"
    #   )
    class TranslationImportService
        # Raised when a value does not match the expected YAML hierarchy.
        class InvalidStructureError < StandardError; end

        # @param file_path [String] absolute or relative path to the YAML file
        # @param platform [String] platform assigned to every module in the file
        # @return [Hash] import summary with created, completed, skipped, and errors
        # @raise [InvalidStructureError] when the YAML hierarchy is invalid
        # @raise [Psych::Exception, SystemCallError] when the file cannot be loaded
        def self.call(file_path:, platform:)
            new(file_path: file_path, platform: platform).call
        end

        def initialize(file_path:, platform:)
            @file_path = file_path
            @platform = platform
        end

        def call
            translations = load_yaml
            validate_structure!(translations)
            summary = empty_summary

            # Import the complete file in a single transaction
            ApplicationRecord.transaction do
                import_translations(translations, summary)
            end

            summary
        end

        private

        attr_reader :file_path, :platform

        # A new summary is built for each call so results are never shared
        # between imports.
        def empty_summary
            {
                created: {
                    modules: 0,
                    buckets: 0,
                    labels: 0
                },
                completed: 0,
                skipped: 0,
                errors: []
            }
        end

        def import_translations(translations, summary)
            # Iterate over every locale in the file
            translations.each do |locale, modules|
                modules.each do |module_code, buckets|

                    # Create the module if it does not exist
                    translation_module = Module.find_or_create_by!(
                        code: module_code,
                        platform: platform
                    )
                    count_creation(summary, :modules, translation_module)

                    # Iterate over the module buckets
                    buckets.each do |bucket_code, labels|

                        # Create the bucket if it does not exist
                        translation_bucket = translation_module.buckets
                            .create_with(reference_module: translation_module.code)
                            .find_or_create_by!(code: bucket_code)
                        count_creation(summary, :buckets, translation_bucket)

                        # Iterate over the bucket labels
                        labels.each do |label, translation|

                            # Create the label if it does not exist
                            translation_label = translation_bucket.labels
                                .create_with(locale => translation)
                                .find_or_create_by!(text: label)
                            count_creation(summary, :labels, translation_label)
                        end
                    end
                end
            end
        end

        # Count only records created during the current import
        def count_creation(summary, resource, record)
            return unless record.previously_new_record?

            summary[:created][resource] += 1
        end

        # Parser and filesystem exceptions intentionally propagate to the caller.
        def load_yaml
            YAML.safe_load_file(file_path, aliases: false)
        end

        def validate_structure!(translations)
            # Only validate the expected YAML hierarchy. Naming conventions and
            # business rules belong to the importer, models, or database.
            #
            # locale:
            #   module:
            #     bucket:
            #       label: "translation"
            expect_hash!(translations, [], "locales")

            translations.each do |locale, modules|
                expect_hash!(modules, [locale], "modules")

                modules.each do |module_code, buckets|
                    expect_hash!(buckets, [locale, module_code], "buckets")

                    buckets.each do |bucket_code, labels|
                        expect_hash!(labels, [locale, module_code, bucket_code], "labels")

                        labels.each do |label, translation|
                            next if translation.is_a?(String)

                            invalid_structure!([locale, module_code, bucket_code, label], "string")
                        end
                    end
                end
            end
        end

        def expect_hash!(value, path, expected)
            return if value.is_a?(Hash)

            # The accumulated path identifies the exact level that cannot be traversed.
            invalid_structure!(path, expected)
        end

        def invalid_structure!(path, expected)
            # Root errors do not have YAML keys that can be joined into a path.
            location = path.any? ? path.map(&:to_s).join(".") : "<root>"
            raise InvalidStructureError,
                "Invalid translation structure at #{location}: expected #{expected}"
        end
    end
end

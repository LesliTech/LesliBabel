require "yaml"

module LesliBabel
    class TranslationImportService
        class InvalidStructureError < StandardError; end

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

        private

        attr_reader :file_path, :platform

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

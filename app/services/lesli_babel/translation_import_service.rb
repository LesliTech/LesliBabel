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
        # @return [Hash] structural errors found while validating the file
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
            errors = []
            translations = validate_structure(translations, errors)

            # Import the complete file in a single transaction
            ApplicationRecord.transaction do
                import_translations(translations)
            end

            { errors: errors }
        end

        private

        attr_reader :file_path, :platform

        def import_translations(translations)
            # Iterate over every locale in the file
            translations.each do |locale, modules|
                modules.each do |module_code, buckets|

                    # Create the module if it does not exist
                    translation_module = Module.find_or_create_by!(
                        code: module_code,
                        platform: platform
                    )

                    # Iterate over the module buckets
                    buckets.each do |bucket_code, labels|

                        # Create the bucket if it does not exist
                        translation_bucket = translation_module.buckets
                            .create_with(reference_module: translation_module.code)
                            .find_or_create_by!(code: bucket_code)

                        # Iterate over the bucket labels
                        labels.each do |label, translation|

                            # Create the label if it does not exist
                            translation_label = translation_bucket.labels
                                .create_with(
                                    locale => translation,
                                    "last_update_#{locale}" => Time.current
                                )
                                .find_or_create_by!(text: label)
                            complete_translation(translation_label, locale, translation)
                        end
                    end
                end
            end
        end

        # Complete an existing label only when its locale is empty
        def complete_translation(translation_label, locale, translation)
            return if translation_label.previously_new_record?
            return if translation_label[locale].present?

            translation_label.update!(
                locale => translation,
                "last_update_#{locale}" => Time.current
            )
        end

        # Parser and filesystem exceptions intentionally propagate to the caller.
        def load_yaml
            YAML.safe_load_file(file_path, permitted_classes: [Symbol], aliases: false)
        end

        def validate_structure(translations, errors)
            # Only validate the expected YAML hierarchy. Naming conventions and
            # business rules belong to the importer, models, or database.
            #
            # locale:
            #   module:
            #     bucket:
            #       label: "translation"

            # Without a root hash there are no independent branches that can be imported.
            return {} unless valid_hash?(translations, [], "locales", errors)

            # Build a clean copy instead of modifying the parsed YAML. Invalid branches
            # are excluded from this hash while their valid siblings remain available.
            valid_translations = {}

            # A locale must contain a hash of modules. If it does not, reject only
            # that locale and continue validating the remaining locales.
            translations.each do |locale, modules|
                next unless valid_hash?(modules, [locale], "modules", errors)

                # Register the locale before traversing it so an empty locale remains valid.
                valid_modules = {}
                valid_translations[locale] = valid_modules

                # A module must contain a hash of buckets.
                modules.each do |module_code, buckets|
                    next unless valid_hash?(buckets, [locale, module_code], "buckets", errors)

                    # Preserve valid modules even when they do not define buckets.
                    valid_buckets = {}
                    valid_modules[module_code] = valid_buckets

                    # A bucket must contain a hash of labels.
                    buckets.each do |bucket_code, labels|
                        path = [locale, module_code, bucket_code]
                        next unless valid_hash?(labels, path, "labels", errors)

                        # Preserve valid buckets even when their label collection is empty.
                        valid_labels = {}
                        valid_buckets[bucket_code] = valid_labels

                        # Label values are the leaves of the supported hierarchy.
                        labels.each do |label, translation|
                            label_path = [locale, module_code, bucket_code, label]

                            if translation.is_a?(String)
                                # Only valid leaves are copied into the importable document.
                                valid_labels[label] = translation
                            else
                                # Reject the invalid label without discarding its siblings.
                                record_invalid_structure(errors, label_path, "string")
                            end
                        end
                    end
                end
            end

            valid_translations
        end

        def valid_hash?(value, path, expected, errors)
            # Returning a boolean lets each level decide which branch to skip.
            return true if value.is_a?(Hash)

            # The accumulated path identifies the exact level that cannot be traversed.
            record_invalid_structure(errors, path, expected)
            false
        end

        def record_invalid_structure(errors, path, expected)
            # Root errors do not have YAML keys that can be joined into a path.
            location = path.any? ? path.map(&:to_s).join(".") : "<root>"

            # Record the error instead of raising it immediately so validation can
            # discover other invalid branches and preserve every valid translation.
            error = InvalidStructureError.new(
                "Invalid translation structure at #{location}: expected #{expected}"
            )
            errors << error.message
        end
    end
end

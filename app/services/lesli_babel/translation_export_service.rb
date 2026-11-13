require "yaml"

module LesliBabel
    # Builds one locale YAML document without writing to the filesystem.
    #
    # The generated hierarchy is locale -> module -> bucket -> label -> string.
    # The engine metadata provides the owning module code and expected locale
    # directory. Every call builds the complete document in memory.
    #
    # @example
    #   LesliBabel::TranslationExportService.call(
    #       engine: LesliSystem.engine("LesliBabel"),
    #       platform: "lesli_engine",
    #       locale: :en
    #   )
    class TranslationExportService
        # @param engine [Hash] engine metadata containing code and dir
        # @param platform [String] platform used to identify the owning module
        # @param locale [String, Symbol] locale column and YAML root
        # @return [Hash] expected file_path and serialized YAML content
        # @raise [ActiveRecord::RecordNotFound] when the owning module does not exist
        def self.call(engine:, platform:, locale:)
            new(engine: engine, platform: platform, locale: locale).call
        end

        def initialize(engine:, platform:, locale:)
            @engine = engine
            @platform = platform
            @locale = locale.to_s
        end

        def call
            # Export only the module owned by the requested engine and platform
            translation_module = Module.find_by(
                code: engine.fetch(:code),
                platform: platform
            )
            unless translation_module
                raise ActiveRecord::RecordNotFound,
                    "Translation module not found: code=#{engine.fetch(:code)}, platform=#{platform}"
            end

            # Return the expected destination and content without writing the file
            {
                file_path: translation_file_path,
                content: build_document(translation_module).to_yaml
            }
        end

        private

        attr_reader :engine, :platform, :locale

        # Build the official locale path inside the owning package
        def translation_file_path
            File.join(
                engine.fetch(:dir),
                "config",
                "locales",
                "translations.#{locale}.yml"
            )
        end

        def build_document(translation_module)
            # Build buckets in code order for deterministic YAML output
            buckets = {}

            translation_module.buckets.order(:code).each do |bucket|
                labels = {}

                # Disabled labels do not belong in generated translation files
                bucket.labels
                    .where("status IS NULL OR status != ?", Label.statuses.fetch("disabled"))
                    .order(:text).each do |label|

                    # Build labels in text order and keep every key as a string
                    labels[label.text.to_s] = translation_value(translation_module, bucket, label)
                end

                buckets[bucket.code.to_s] = labels
            end

            # Use string keys for the locale and module roots
            {
                locale => {
                    translation_module.code.to_s => buckets
                }
            }
        end

        def translation_value(translation_module, bucket, label)
            value = label[locale]
            return value if value.present?

            # Represent missing values with their complete translation path
            ":#{translation_module.code}.#{bucket.code}.#{label.text}:"
        end
    end
end

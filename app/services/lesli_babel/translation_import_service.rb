require "yaml"

module LesliBabel
    class TranslationImportService
        def self.call(file_path:, platform:)
            new(file_path: file_path, platform: platform).call
        end

        def initialize(file_path:, platform:)
            @file_path = file_path
            @platform = platform
        end

        def call
            load_yaml

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
    end
end

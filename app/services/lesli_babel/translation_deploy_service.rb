require "tempfile"

module LesliBabel
    # Writes exported translation documents to their official locale paths.
    #
    # Every document is generated and staged before a destination is replaced.
    # Temporary files live beside their destinations so File.rename performs an
    # atomic replacement on the same filesystem.
    class TranslationDeployService
        # @return [Hash] deployed file paths and export errors
        # @raise [SystemCallError] when a filesystem operation fails
        def self.call
            new.call
        end

        def call
            documents, errors = build_documents
            return { files: [], errors: errors } if errors.any?

            verify_destinations!(documents)
            staged_documents = stage_documents(documents)
            files = replace_destinations(staged_documents)

            { files: files, errors: [] }
        ensure
            cleanup_temporary_files(staged_documents)
        end

        private

        # Generate every document before performing filesystem operations
        def build_documents
            documents = []
            errors = []

            engines.each do |engine|
                locales.each do |locale|
                    documents << TranslationExportService.call(
                        engine: export_engine(engine),
                        platform: platform_for(engine),
                        locale: locale
                    )
                rescue ActiveRecord::RecordNotFound, ActiveModel::MissingAttributeError => error
                    errors << "#{engine[:name]}/#{locale}: #{error.message}"
                end
            end

            [documents, errors]
        end

        # Root is the host application; Lesli is the core engine
        def platform_for(engine)
            return "rails_app" if engine[:code] == "root"
            return "lesli_core" if engine[:code] == "lesli"

            "lesli_engine"
        end

        # The host application owns main_app even though its catalog code is root
        def export_engine(engine)
            return engine unless engine[:code] == "root"

            engine.merge(code: "main_app")
        end

        def engines
            LesliSystem.engines.values.sort_by { |engine| engine[:name].to_s }
        end

        def locales
            Lesli.config.babel.fetch(:locales).keys.map(&:to_s).sort
        end

        # Verify every destination before creating or replacing any file
        def verify_destinations!(documents)
            file_paths = documents.map { |document| document.fetch(:file_path) }
            duplicate_path = file_paths.tally.find { |_path, count| count > 1 }&.first
            raise ArgumentError, "Duplicate translation destination: #{duplicate_path}" if duplicate_path

            file_paths.each do |file_path|
                directory = File.dirname(file_path)

                raise Errno::ENOENT, directory unless File.directory?(directory)
                raise Errno::EACCES, directory unless File.writable?(directory)
                raise Errno::EACCES, file_path if File.exist?(file_path) && !File.writable?(file_path)
            end
        end

        # Write every document to a temporary file beside its destination
        def stage_documents(documents)
            staged_documents = []

            documents.each do |document|
                file_path = document.fetch(:file_path)
                temporary_file = Tempfile.new(
                    [".#{File.basename(file_path)}-", ".tmp"],
                    File.dirname(file_path)
                )
                staged_document = {
                    file_path: file_path,
                    temporary_file: temporary_file
                }
                staged_documents << staged_document

                temporary_file.binmode
                temporary_file.write(document.fetch(:content))
                temporary_file.flush
                temporary_file.fsync
                temporary_file.chmod(file_mode(file_path))
                temporary_file.close
            end

            staged_documents
        rescue
            cleanup_temporary_files(staged_documents)
            raise
        end

        def file_mode(file_path)
            return File.stat(file_path).mode & 0o777 if File.exist?(file_path)

            0o644
        end

        # Rename each staged file over its destination atomically
        def replace_destinations(staged_documents)
            staged_documents.map do |document|
                File.rename(
                    document.fetch(:temporary_file).path,
                    document.fetch(:file_path)
                )
                document.fetch(:file_path)
            end
        end

        def cleanup_temporary_files(staged_documents)
            Array(staged_documents).each do |document|
                temporary_file = document.fetch(:temporary_file)
                temporary_file.close unless temporary_file.closed?
                temporary_file.unlink if File.exist?(temporary_file.path)
            end
        end
    end
end

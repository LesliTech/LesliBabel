module LesliBabel
    # Builds the translation statistics displayed by the Babel dashboard.
    class TranslationService < Lesli::ApplicationLesliService

        def stats
            labels = LabelService.new(current_user, query).builder
            label_count = labels.reselect(:id).count

            locales = Lesli.config.babel.fetch(:locales).map do |locale_code, locale_name|
                completed = labels
                    .reselect(:id)
                    .where.not(locale_code => [nil, ""])
                    .count

                {
                    code: locale_code,
                    name: locale_name,
                    completed: completed,
                    missing: label_count - completed,
                    coverage: coverage(completed, label_count)
                }
            end

            completed_translations = locales.sum { |locale| locale[:completed] }
            pending_translations = locales.sum { |locale| locale[:missing] }
            status_counts = labels.reselect(:status).group(:status).count

            {
                total_labels: label_count,
                locales: locales.sort_by { |locale| [locale[:coverage], locale[:name].to_s] },
                summary: {
                    configured_locales: locales.size,
                    pending_translations: pending_translations,
                    coverage: coverage(
                        completed_translations,
                        completed_translations + pending_translations
                    )
                },
                attention: {
                    need_translation: status_counts.fetch("need_translation", 0),
                    need_help: status_counts.fetch("need_help", 0),
                    need_context: status_counts.fetch("need_context", 0)
                }
            }
        end

        private

        def coverage(completed, total)
            return 0 if total.zero?

            (completed * 100.0 / total).round
        end
    end
end

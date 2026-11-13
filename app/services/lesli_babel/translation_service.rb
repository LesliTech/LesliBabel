module LesliBabel
    # Builds the translation statistics displayed by the Babel dashboard.
    class TranslationService < Lesli::ApplicationLesliService

        def stats
            labels = LabelService.new(current_user, query).builder
            translatable_labels = labels.where(
                "lesli_babel_labels.status IS NULL OR lesli_babel_labels.status != ?",
                Label.statuses.fetch("disabled")
            )
            translatable_count = translatable_labels.reselect(:id).count

            locales = Lesli.config.babel.fetch(:locales).map do |locale_code, locale_name|
                completed = translatable_labels
                    .reselect(:id)
                    .where.not(locale_code => [nil, ""])
                    .count

                {
                    code: locale_code,
                    name: locale_name,
                    completed: completed,
                    missing: translatable_count - completed,
                    coverage: coverage(completed, translatable_count)
                }
            end

            completed_translations = locales.sum { |locale| locale[:completed] }
            pending_translations = locales.sum { |locale| locale[:missing] }

            {
                total_labels: labels.reselect(:id).count,
                locales: locales,
                summary: {
                    configured_locales: locales.size,
                    pending_translations: pending_translations,
                    coverage: coverage(
                        completed_translations,
                        completed_translations + pending_translations
                    )
                },
                attention: {
                    need_translation: labels.where(status: :need_translation).reselect(:id).count,
                    need_help: labels.where(status: :need_help).reselect(:id).count,
                    need_context: labels.where(status: :need_context).reselect(:id).count
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

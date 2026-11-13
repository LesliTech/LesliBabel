module LesliBabel
    # Builds the translation statistics displayed by the Babel dashboard.
    class TranslationService < Lesli::ApplicationLesliService

        def stats
            Rails.cache.fetch(cache_key_for_account(__method__), expires_in: 1.hour) do
                labels = LabelService.new(current_user, query).builder
                total_strings_translations = Lesli.config.babel.fetch(:locales).map do |locale_code, locale_name|
                    {
                        code: locale_code,
                        name: locale_name,
                        total: labels
                            .reselect(:id)
                            .where.not(locale_code => [nil, ""])
                            .count
                    }
                end

                {
                    total_strings: labels.reselect(:id).count,
                    total_strings_translations: total_strings_translations,
                    total_strings_waiting_for_help: 0,
                    total_strings_waiting_for_translation: 0
                }
            end
        end
    end
end

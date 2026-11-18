module LesliBabel
    module LabelsHelper
        TRANSLATION_TOKEN_PATTERN = /%\{[^}]+\}|(?<![\w:]):[a-zA-Z_][a-zA-Z0-9_]*/
        STATUS_BADGE_CLASSES = {
            "ok" => "bg-success-50 text-success-700 ring-success-200",
            "need_help" => "bg-warning-50 text-warning-700 ring-warning-200",
            "need_context" => "bg-info-50 text-info-700 ring-info-200",
            "need_translation" => "bg-danger-50 text-danger-700 ring-danger-200"
        }.freeze
        STATUS_BORDER_CLASSES = {
            "ok" => "border-success-300",
            "need_help" => "border-warning-300",
            "need_context" => "border-info-300",
            "need_translation" => "border-danger-300"
        }.freeze

        def translation_field_message(label, locale)
            value = label.public_send(locale).to_s
            messages = []
            messages << "Missing translation" if value.blank?

            tokens = value.scan(TRANSLATION_TOKEN_PATTERN).uniq
            messages << "Tokens: #{tokens.join(', ')}" if tokens.any?

            messages.join(" · ").presence
        end

        def missing_translation_languages(label)
            Lesli.config.babel.fetch(:locales).filter_map do |locale, language|
                language if label.public_send(locale).blank?
            end
        end

        def label_status_name(status)
            return "OK" if status.to_s == "ok"

            status.to_s.humanize.presence || "Not set"
        end

        def label_status_badge_classes(status)
            classes = STATUS_BADGE_CLASSES.fetch(
                status.to_s,
                "bg-neutral-100 text-neutral-600 ring-neutral-200"
            )

            "inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset #{classes}"
        end

        def label_status_border_class(status)
            STATUS_BORDER_CLASSES.fetch(status.to_s, "border-neutral-200")
        end
    end
end

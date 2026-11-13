module LesliBabel
    module LabelsHelper
        TRANSLATION_TOKEN_PATTERN = /%\{[^}]+\}|(?<![\w:]):[a-zA-Z_][a-zA-Z0-9_]*/
        STATUS_BADGE_CLASSES = {
            "ok" => "bg-emerald-50 text-emerald-700 ring-emerald-200",
            "disabled" => "bg-slate-100 text-slate-600 ring-slate-200",
            "need_help" => "bg-amber-50 text-amber-700 ring-amber-200",
            "need_context" => "bg-sky-50 text-sky-700 ring-sky-200",
            "need_translation" => "bg-rose-50 text-rose-700 ring-rose-200"
        }.freeze
        STATUS_BORDER_CLASSES = {
            "ok" => "border-emerald-300",
            "disabled" => "border-slate-300",
            "need_help" => "border-amber-300",
            "need_context" => "border-sky-300",
            "need_translation" => "border-rose-300"
        }.freeze

        def translation_field_message(label, locale)
            value = label.public_send(locale).to_s
            messages = []
            messages << "Missing translation" if value.blank?

            tokens = value.scan(TRANSLATION_TOKEN_PATTERN).uniq
            messages << "Tokens: #{tokens.join(', ')}" if tokens.any?

            messages.join(" · ").presence
        end

        def label_status_name(status)
            return "OK" if status.to_s == "ok"

            status.to_s.humanize.presence || "Not set"
        end

        def label_status_badge_classes(status)
            classes = STATUS_BADGE_CLASSES.fetch(
                status.to_s,
                "bg-slate-100 text-slate-600 ring-slate-200"
            )

            "inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset #{classes}"
        end

        def label_status_border_class(status)
            STATUS_BORDER_CLASSES.fetch(status.to_s, "border-slate-200")
        end
    end
end

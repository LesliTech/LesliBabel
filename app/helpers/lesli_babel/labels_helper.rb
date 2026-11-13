module LesliBabel
    module LabelsHelper
        TRANSLATION_TOKEN_PATTERN = /%\{[^}]+\}|(?<![\w:]):[a-zA-Z_][a-zA-Z0-9_]*/

        def translation_field_message(label, locale)
            value = label.public_send(locale).to_s
            messages = []
            messages << "Missing translation" if value.blank?

            tokens = value.scan(TRANSLATION_TOKEN_PATTERN).uniq
            messages << "Tokens: #{tokens.join(', ')}" if tokens.any?

            messages.join(" · ").presence
        end
    end
end

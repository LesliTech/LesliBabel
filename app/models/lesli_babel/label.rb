module LesliBabel
    class Label < ApplicationRecord
        belongs_to :bucket

        enum :status, {
            :ok => "ok",
            :disabled => "disabled",
            :need_help => "need_help",
            :need_context => "need_context",
            :need_translation => "need_translation"
        }
    end
end

module CloudBabel
    class Translation < ApplicationRecord

        enum locales: {
            en: "en",
            es: "es",
            de: "de",
            fr: "fr"
        }
    end
end

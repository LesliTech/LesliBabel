module LesliBabel
    class TranslationService < Lesli::ApplicationLesliService

        def stats

            #Rails.cache.fetch("babel/strings/stats", expires_in: 1.hour) do

                label_service = LabelService.new(current_user, query)

                # total translations registered in babel
                total_strings = label_service.builder.reselect(:id).count
                
                # total translations by language
                total_strings_translations = []

                Lesli.config.locales.each do |locale|
                    total_strings_translations.push({
                        code: locale[0],
                        name: locale[1],
                        total: label_service.builder.reselect(:id).where("#{locale[0]} is not null").where("#{locale[0]} != ''").count
                    })
                end

                # total translations that needs help
                total_strings_waiting_for_help = 0#self.list.reselect(:id).where(:status => 1).count

                # total translations that needs translation
                total_strings_waiting_for_translation = 0 #self.list.reselect(:id).where(:status => 2).count

                {
                    total_strings: total_strings,
                    total_strings_translations: total_strings_translations,
                    total_strings_waiting_for_help: total_strings_waiting_for_help,
                    total_strings_waiting_for_translation: total_strings_waiting_for_translation
                }
            #end
        end
    end
end

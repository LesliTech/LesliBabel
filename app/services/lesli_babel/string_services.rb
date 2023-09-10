module LesliBabel
    class StringServices < LesliServices

        def self.strings engines_id=nil, buckets_id=nil

            # get strings with bucket and module information
            strings = String
            .joins("inner join cloud_babel_buckets on cloud_babel_buckets.id = cloud_babel_strings.cloud_babel_buckets_id and cloud_babel_buckets.deleted_at is NULL")
            .joins("inner join cloud_babel_modules on cloud_babel_modules.id = cloud_babel_buckets.cloud_babel_modules_id and cloud_babel_modules.deleted_at is NULL")
            .where("cloud_babel_modules.id in (?)", ModuleServices.installed_engines_id)

            # filter by specific engines
            if engines_id
                strings = strings.where("cloud_babel_modules.id in (?)", engines_id)
            end

            # filter by specific engine buckets 
            if buckets_id
                strings = strings.where("cloud_babel_buckets.id in (?)", buckets_id)
            end

            strings
        end

        def self.stats

            Rails.cache.fetch("translations-stats", expires_in: 1.hour) do

                # total translations registered in babel
                total_strings = strings.count
                
                # total translations by language
                total_strings_translations = []
                
                Rails.application.config.lesli.dig(:configuration, :locales_available).each do |locale|
                    total_strings_translations.push({
                        code: locale[0],
                        name: locale[1],
                        total: strings.where("#{locale[0]} is not null").where("#{locale[0]} != ''").count
                    })
                end

                # total translations that needs help
                total_strings_waiting_for_help = strings.where(:need_help => true).count

                # total translations that needs translation
                total_strings_waiting_for_translation = strings.where(:need_translation => true).count

                {
                    total_strings: total_strings,
                    total_strings_translations: total_strings_translations,
                    total_strings_waiting_for_help: total_strings_waiting_for_help,
                    total_strings_waiting_for_translation: total_strings_waiting_for_translation
                }

            end
        end
    end
end

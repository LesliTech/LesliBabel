module LesliBabel
    class StringService < Lesli::ApplicationLesliService

        def list engines_id=nil, buckets_id=nil

            # get strings with bucket and module information
            strings = String
            .joins("inner join lesli_babel_buckets on lesli_babel_buckets.id = lesli_babel_strings.bucket_id and lesli_babel_buckets.deleted_at is NULL")
            .joins("inner join lesli_babel_modules on lesli_babel_modules.id = lesli_babel_buckets.module_id and lesli_babel_modules.deleted_at is NULL")
            .where("lesli_babel_modules.id in (?)", ModuleService.new(current_user, query).list())

            # filter by specific engines
            if engines_id
                strings = strings.where("lesli_babel_modules.id in (?)", engines_id)
            end

            # filter by specific engine buckets 
            if buckets_id
                strings = strings.where("lesli_babel_buckets.id in (?)", buckets_id)
            end

            strings.select(
                :id,
                :label,
                :status,
                :context,
                Lesli.config.locales.keys,
                "lesli_babel_modules.id as engine_id",
                "lesli_babel_buckets.id as bucket_id",
                "lesli_babel_buckets.code as bucket_code",
                "lesli_babel_modules.code as engine_code",
                "lesli_babel_modules.platform as platform",
                "'' as path"
            )

        end

        def index params
            self.list(params[:module])
            .page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
            .order(:updated_at)
        end

        def stats

            Rails.cache.fetch("babel/strings/stats", expires_in: 1.hour) do

                # total translations registered in babel
                total_strings = self.list.reselect(:id).count
                
                # total translations by language
                total_strings_translations = []

                Lesli.config.locales.each do |locale|
                    total_strings_translations.push({
                        code: locale[0],
                        name: locale[1],
                        total: self.list.reselect(:id).where("#{locale[0]} is not null").where("#{locale[0]} != ''").count
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
            end
        end
    end
end

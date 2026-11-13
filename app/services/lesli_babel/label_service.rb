module LesliBabel
    class LabelService < Lesli::ApplicationLesliService

        def find id 
            super(Label.find_by_id(id))
        end

        def builder modules_id:nil, buckets_id:nil

            # get strings with bucket and module information
            strings = Label
            .joins("inner join lesli_babel_buckets on lesli_babel_buckets.id = lesli_babel_labels.bucket_id")
            .joins("inner join lesli_babel_modules on lesli_babel_modules.id = lesli_babel_buckets.module_id")

            # filter by specific engines
            if modules_id
                strings = strings.where("lesli_babel_modules.id in (?)", modules_id)
            end

            # filter by specific engine buckets 
            if buckets_id
                strings = strings.where("lesli_babel_buckets.id in (?)", buckets_id)
            end

            strings.select(
                :id,
                :text,
                :status,
                :context,
                Lesli.config.babel.dig(:locales).keys,
                "lesli_babel_modules.id as engine_id",
                "lesli_babel_buckets.id as bucket_id",
                "lesli_babel_buckets.code as bucket_code",
                "lesli_babel_modules.code as engine_code",
                "lesli_babel_modules.platform as platform",
                "concat_ws('.', lesli_babel_modules.code, lesli_babel_buckets.code, text) as path"
            )

        end

        def index params
            labels = self.builder(modules_id:params[:modules_id])
            condition = missing_condition(params)

            if condition
                labels = labels.where(condition)
            end

            labels
            .page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
            .order(status: :desc, updated_at: :desc, id: :desc)
        end

        def show 
            self.builder.find_by_id(self.resource.id)
        end

        private

        def missing_condition(params)
            return unless params[:missing].to_s == "true"

            locales = Lesli.config.babel.fetch(:locales).keys.map(&:to_s)
            requested_locale = params[:locale].to_s

            if requested_locale.present?
                return unless locales.include?(requested_locale)

                locales = [requested_locale]
            end

            locales
                .map { |locale| missing_value_for(locale) }
                .reduce { |condition, locale| condition.or(locale) }
        end

        def missing_value_for(locale)
            column = Label.arel_table[locale]
            column.eq(nil).or(column.eq(""))
        end
    end
end

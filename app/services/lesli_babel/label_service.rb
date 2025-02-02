module LesliBabel
    class LabelService < Lesli::ApplicationLesliService

        def find id 
            super(self.builder.find_by_id(id))
        end

        def builder modules_id:nil, buckets_id:nil

            # get strings with bucket and module information
            strings = Label
            .joins("inner join lesli_babel_buckets on lesli_babel_buckets.id = lesli_babel_labels.bucket_id and lesli_babel_buckets.deleted_at is NULL")
            .joins("inner join lesli_babel_modules on lesli_babel_modules.id = lesli_babel_buckets.module_id and lesli_babel_modules.deleted_at is NULL")
            .where("lesli_babel_labels.status != 0 OR lesli_babel_labels.status is NULL")

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
            self.builder(modules_id:params[:modules_id])
            .page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
            .order(status: :desc )
            .order(updated_at: :desc)
        end

        def show 
            self.resource
        end
    end
end

require_dependency "cloud_babel/application_controller"

module CloudBabel
    class Translation::StringsController < ApplicationController
        before_action :set_translation_string, only: [:show, :edit, :update, :destroy, :need_help, :need_translation]

        # GET /translation/strings
        def index
            respond_to do |format|
                format.html { }
                format.json { 

                    # empty strings by default
                    strings = []

                    # if bucket or module was not sent, return all the strings in the database with missing german translation
                    if params[:module_id].blank? and params[:bucket_id].blank?
                        strings = Translation::String.where(:need_translation => true)
                        .or(Translation::String.where(:de => nil))
                        .or(Translation::String.where(:de => ""))
                        .order(:created_at)
                    end

                    # returns strings for specif module
                    if not params[:module_id].blank? and params[:bucket_id].blank?
                        strings = Translation::String.joins(:bucket)
                            .where("cloud_babel_translation_buckets.cloud_babel_translation_modules_id = ?", params[:module_id])
                    end

                    # returns strings for specif module and bucket
                    if not params[:module_id].blank? and not params[:bucket_id].blank?
                        bucket = Translation::Bucket.find(params[:bucket_id])
                        strings = bucket.strings
                    end

                    count = strings.length

                    strings = strings
                    .page(@query[:pagination][:page])
                    .per(@query[:pagination][:perPage])
                    .order(:updated_at)

                    strings = strings.map do |string|
                        {
                            id: string.id,
                            path: string.path,
                            context: string.context,
                            label: string.label,
                            es: string.es,
                            en: string.en,
                            de: string.de,
                            fr: string.fr,
                            status: string.status,
                            need_help: string.need_help || false,
                            need_translation: string.need_translation || false
                        }
                    end

                    respond_with_successful({
                        total: count,
                        data: strings
                    })

                }
            end
        end

        # GET /translation/strings/1
        def show
        end

        # GET /translation/strings/new
        def new
            @translation_string = Translation::String.new
        end

        # GET /translation/strings/1/edit
        def edit
        end

        # POST /translation/strings
        def create

            translation_string = Translation::String.new(translation_string_params)
            translation_string.reference_bucket = "#{translation_string.bucket.module.name}-#{translation_string.bucket.name}"
            translation_string.user = current_user

            translation_string.last_update_status = Time.now
            translation_string.last_update_context = Time.now
            Translation.locales.each do |locale|
                translation_string["last_update_#{locale[0]}"] = Time.now
            end
            
            if translation_string.save
                responseWithSuccessful(translation_string)
            else
                responseWithError("Error on create translation string", translation_string.errors)
            end

        end

        # PATCH/PUT /translation/strings/1
        def update

            # if status changed
            if @translation_string["status"] != translation_string_params["status"]

                # saved update date
                @translation_string["last_update_status"] = Time.now

            end

            # if context changed
            if @translation_string["context"] != translation_string_params["context"]

                # saved update date
                @translation_string["last_update_context"] = Time.now

            end

            Translation.locales.each do |locale|
            
                locale = locale[0]

                # if translation changed
                if @translation_string[locale] != translation_string_params[locale]

                    # saved update date
                    @translation_string["last_update_#{locale}"] = Time.now

                end

            end

            if @translation_string.update(translation_string_params)
                @translation_string.update_attribute(:need_help, false)
                responseWithSuccessful(@translation_string)
            else
                responseWithError("Error on update translation string", @translation_object_group_section_label.errors)
            end

        end

        # DELETE /translation/strings/1
        def destroy
            #@translation_string.destroy
            @translation_string.deleted_at = Time.now
            @translation_string.save!
            responseWithSuccessful()
        end

        def need_help
            @translation_string.need_help = true
            @translation_string.save!
            responseWithSuccessful()
        end

        def need_translation
            @translation_string.need_translation = true
            @translation_string.save!
            responseWithSuccessful()
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_translation_string
            @translation_string = Translation::String.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_string_params
            params.require(:translation_string).permit(
                :context, 
                :label, 
                :en, 
                :es, 
                :de, 
                :status,
                :cloud_babel_translation_buckets_id
            )
        end

    end
end

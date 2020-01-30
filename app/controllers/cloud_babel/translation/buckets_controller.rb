require_dependency "cloud_babel/application_controller"

module CloudBabel
    class Translation::BucketsController < ApplicationController
        before_action :set_translation_bucket, only: [:show, :edit, :update, :destroy]

        # GET /translation/buckets
        def index
            translation_buckets = Translation::Module.find(params[:module_id]).buckets
            respond_to do |format|
                format.html { }
                format.json { responseWithSuccessful(translation_buckets) }
            end
        end

        # GET /translation/buckets/1
        def show
        end

        # GET /translation/buckets/new
        def new
        @translation_bucket = Translation::Bucket.new
        end

        # GET /translation/buckets/1/edit
        def edit
        end

        # POST /translation/buckets
        def create
        @translation_bucket = Translation::Bucket.new(translation_bucket_params)

        if @translation_bucket.save
        redirect_to @translation_bucket, notice: 'Bucket was successfully created.'
        else
        render :new
        end
        end

        # PATCH/PUT /translation/buckets/1
        def update
        if @translation_bucket.update(translation_bucket_params)
        redirect_to @translation_bucket, notice: 'Bucket was successfully updated.'
        else
        render :edit
        end
        end

        # DELETE /translation/buckets/1
        def destroy
        @translation_bucket.destroy
        redirect_to translation_buckets_url, notice: 'Bucket was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_translation_bucket
        @translation_bucket = Translation::Bucket.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_bucket_params
        params.fetch(:translation_bucket, {})
        end
    end
end

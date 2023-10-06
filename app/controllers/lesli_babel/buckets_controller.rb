

module LesliBabel
    class BucketsController < ApplicationController
        before_action :set_bucket, only: [:show, :edit, :update, :destroy]

        # GET /buckets
        def index
            respond_to do |format|
                format.html { }
                format.json { 
                    respond_with_successful(
                        Module.find(params[:module_id]).buckets.order(name: :asc)
                    ) 
                }
            end
        end

        # GET /buckets/1
        def show
        end

        # GET /buckets/new
        def new
        @bucket = Bucket.new
        end

        # GET /buckets/1/edit
        def edit
        end

        # POST /buckets
        def create
            bucket = Bucket.new(bucket_params)
            bucket.module = Module.find(params[:module_id])
            bucket.reference_module = bucket.module.name

            if bucket.save
                respond_with_successful bucket
            else
                respond_with_error bucket.errors.full_messages
            end
        end

        # PATCH/PUT /buckets/1
        def update
        if @bucket.update(bucket_params)
        redirect_to @bucket, notice: 'Bucket was successfully updated.'
        else
        render :edit
        end
        end

        # DELETE /buckets/1
        def destroy
        @bucket.destroy
        redirect_to buckets_url, notice: 'Bucket was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_bucket
            @bucket = Bucket.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def bucket_params
            params.require(:bucket).permit(:name)
        end

    end
end

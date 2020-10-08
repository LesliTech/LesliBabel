require_dependency "cloud_babel/application_controller"

module CloudBabel
  class Bucket::DiscussionsController < ApplicationController
    before_action :set_bucket_discussion, only: [:show, :edit, :update, :destroy]

    # GET /bucket/discussions
    def index
      @bucket_discussions = Bucket::Discussion.all
    end

    # GET /bucket/discussions/1
    def show
    end

    # GET /bucket/discussions/new
    def new
      @bucket_discussion = Bucket::Discussion.new
    end

    # GET /bucket/discussions/1/edit
    def edit
    end

    # POST /bucket/discussions
    def create
      @bucket_discussion = Bucket::Discussion.new(bucket_discussion_params)

      if @bucket_discussion.save
        redirect_to @bucket_discussion, notice: 'Discussion was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /bucket/discussions/1
    def update
      if @bucket_discussion.update(bucket_discussion_params)
        redirect_to @bucket_discussion, notice: 'Discussion was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /bucket/discussions/1
    def destroy
      @bucket_discussion.destroy
      redirect_to bucket_discussions_url, notice: 'Discussion was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_bucket_discussion
        @bucket_discussion = Bucket::Discussion.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def bucket_discussion_params
        params.fetch(:bucket_discussion, {})
      end
  end
end

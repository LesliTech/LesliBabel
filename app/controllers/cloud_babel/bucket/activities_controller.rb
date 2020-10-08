require_dependency "cloud_babel/application_controller"

module CloudBabel
  class Bucket::ActivitiesController < ApplicationController
    before_action :set_bucket_activity, only: [:show, :edit, :update, :destroy]

    # GET /bucket/activities
    def index
      @bucket_activities = Bucket::Activity.all
    end

    # GET /bucket/activities/1
    def show
    end

    # GET /bucket/activities/new
    def new
      @bucket_activity = Bucket::Activity.new
    end

    # GET /bucket/activities/1/edit
    def edit
    end

    # POST /bucket/activities
    def create
      @bucket_activity = Bucket::Activity.new(bucket_activity_params)

      if @bucket_activity.save
        redirect_to @bucket_activity, notice: 'Activity was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /bucket/activities/1
    def update
      if @bucket_activity.update(bucket_activity_params)
        redirect_to @bucket_activity, notice: 'Activity was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /bucket/activities/1
    def destroy
      @bucket_activity.destroy
      redirect_to bucket_activities_url, notice: 'Activity was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_bucket_activity
        @bucket_activity = Bucket::Activity.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def bucket_activity_params
        params.fetch(:bucket_activity, {})
      end
  end
end

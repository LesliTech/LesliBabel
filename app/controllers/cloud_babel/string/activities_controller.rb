require_dependency "cloud_babel/application_controller"

module CloudBabel
  class String::ActivitiesController < ApplicationController
    before_action :set_string_activity, only: [:show, :edit, :update, :destroy]

    # GET /string/activities
    def index
      @string_activities = String::Activity.all
    end

    # GET /string/activities/1
    def show
    end

    # GET /string/activities/new
    def new
      @string_activity = String::Activity.new
    end

    # GET /string/activities/1/edit
    def edit
    end

    # POST /string/activities
    def create
      @string_activity = String::Activity.new(string_activity_params)

      if @string_activity.save
        redirect_to @string_activity, notice: 'Activity was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /string/activities/1
    def update
      if @string_activity.update(string_activity_params)
        redirect_to @string_activity, notice: 'Activity was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /string/activities/1
    def destroy
      @string_activity.destroy
      redirect_to string_activities_url, notice: 'Activity was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_string_activity
        @string_activity = String::Activity.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def string_activity_params
        params.fetch(:string_activity, {})
      end
  end
end

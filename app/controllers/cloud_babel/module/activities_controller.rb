require_dependency "cloud_babel/application_controller"

module CloudBabel
  class Module::ActivitiesController < ApplicationController
    before_action :set_module_activity, only: [:show, :edit, :update, :destroy]

    # GET /module/activities
    def index
      @module_activities = Module::Activity.all
    end

    # GET /module/activities/1
    def show
    end

    # GET /module/activities/new
    def new
      @module_activity = Module::Activity.new
    end

    # GET /module/activities/1/edit
    def edit
    end

    # POST /module/activities
    def create
      @module_activity = Module::Activity.new(module_activity_params)

      if @module_activity.save
        redirect_to @module_activity, notice: 'Activity was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /module/activities/1
    def update
      if @module_activity.update(module_activity_params)
        redirect_to @module_activity, notice: 'Activity was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /module/activities/1
    def destroy
      @module_activity.destroy
      redirect_to module_activities_url, notice: 'Activity was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_module_activity
        @module_activity = Module::Activity.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def module_activity_params
        params.fetch(:module_activity, {})
      end
  end
end

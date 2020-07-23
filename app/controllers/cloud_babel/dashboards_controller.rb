require_dependency "cloud_babel/application_controller"

module CloudBabel
    class DashboardsController < ApplicationController
        before_action :set_dashboard, only: [:edit, :update, :destroy]

        def stats
        end

        def show
        end

    end
end

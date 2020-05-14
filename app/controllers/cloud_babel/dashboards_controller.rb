require_dependency "cloud_babel/application_controller"

module CloudBabel
    class DashboardsController < ApplicationController
        before_action :set_dashboard, only: [:show, :edit, :update, :destroy]

        def stats

        end

    end
end

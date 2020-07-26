require_dependency "cloud_babel/application_controller"

module CloudBabel
    class DashboardsController < ApplicationController
<<<<<<< HEAD
=======
        before_action :set_dashboard, only: [:edit, :update, :destroy]

        def stats
        end
>>>>>>> 4fff7b0c08e3ed820a67600601238c0efa1cf714

        def show
        end

    end
end

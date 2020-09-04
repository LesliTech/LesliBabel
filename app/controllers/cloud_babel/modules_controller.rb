require_dependency "cloud_babel/application_controller"

module CloudBabel
    class ModulesController < ApplicationController
        #before_action :set_module, only: [:show, :edit, :update, :destroy]

        # GET /modules
        def index
        end

        # GET /modules/1
        def show
        end

        # GET /modules/new
        def new
        end

        # GET /modules/1/edit
        def edit
        end

        # POST /modules
        def create
        end

        # PATCH/PUT /modules/1
        def update
        end

        # DELETE /modules/1
        def destroy
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_module
            #@module = Module.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def module_params
        end
    end
end

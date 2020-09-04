require_dependency "cloud_babel/application_controller"

module CloudBabel
    class ModulesController < ApplicationController
        before_action :set_module, only: [:show, :edit, :update, :destroy]

        # GET /modules
        def index
            respond_to do |format|
                format.html {}
                format.json {
                    respond_with_successful(Translation::Module.index)
                }
            end
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
            new_module = Translation::Module.new(module_params)
            if new_module.save
                respond_with_successful(new_module)
            else
                respond_with_error("Error on create module", new_module.errors)
            end
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
            params.require(:module).permit(:name, :module_type)
        end
    end
end

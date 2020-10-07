require_dependency "cloud_babel/application_controller"

module CloudBabel
    class ModulesController < ApplicationController
        before_action :set_module, only: [:show, :edit, :update, :destroy]

        # GET /modules
        def index
            respond_to do |format|
                format.html { }
                format.json { respond_with_successful(Module.index) }
            end
        end

        # GET /modules/1
        def show
        end

        # GET /modules/new
        def new
        @module = Module.new
        end

        # GET /modules/1/edit
        def edit
        end

        # POST /modules
        def create
        @module = Module.new(module_params)

        if @module.save
        redirect_to @module, notice: 'Module was successfully created.'
        else
        render :new
        end
        end

        # PATCH/PUT /modules/1
        def update
        if @module.update(module_params)
        redirect_to @module, notice: 'Module was successfully updated.'
        else
        render :edit
        end
        end

        # DELETE /modules/1
        def destroy
        @module.destroy
        redirect_to modules_url, notice: 'Module was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_module
        @module = Module.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def module_params
        params.fetch(:module, {})
        end
    end
end

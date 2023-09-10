=begin

Copyright (c) 2022, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

require_dependency "cloud_babel/application_controller"

module LesliBabel
    class ModulesController < ApplicationController
        before_action :set_module, only: [:show, :edit, :update, :destroy]

        def privileges 
            {
                show: ['CloudBabel::StringsController#index']
            }
        end

        # GET /modules
        def index
            respond_to do |format|
                format.html { }
                format.json { respond_with_successful(Module.index) }
            end
        end

        # GET /modules/1
        def show
            respond_to do |format|
                format.html { }
                format.json { respond_with_successful(@module) }
            end
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
            new_module = Module.new(module_params)
            if new_module.save
                respond_with_successful(new_module)
            else
                respond_with_error("Error on create module", new_module.errors)
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
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_module
            @module = Module.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def module_params
            params.require(:module).permit(:name, :platform)
        end
    end
end

=begin

Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

module LesliBabel
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

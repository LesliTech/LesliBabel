=begin

Copyright (c) 2021, all rights reserved.

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
    class ClonesController < ApplicationController

        # GET /clones/1
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    return respond_with_successful()
                end
            end
        end

        # GET /clones/new
        def new
        end

        # GET /clones/1/edit
        def edit
        end

        # POST /clones
        def create
            
            result = TranslationsCloneService.remote_clone(clone_params[:instance_code])
            respond_with_successful if result.success?
            respond_with_error if not result.success?

        end

        # PATCH/PUT /clones/1
        def update
            return respond_with_not_found unless @clone

            if @clone.update(clone_params)
                respond_with_successful(@clone.show(current_user, @query))
            else
                respond_with_error(@clone.errors.full_messages.to_sentence)
            end
        end

        # DELETE /clones/1
        def destroy
            return respond_with_not_found unless @clone

            if @clone.destroy
                respond_with_successful
            else
                respond_with_error(@clone.errors.full_messages.to_sentence)
            end
        end

        private

        # Only allow a list of trusted parameters through.
        def clone_params
            params.require(:clone).permit(:instance_code)
        end
    end
end

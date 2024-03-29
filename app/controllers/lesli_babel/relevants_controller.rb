=begin
Copyright (c) 2023, all rights reserved.

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
require_dependency "lesli_babel/application_controller"

module LesliBabel
    class RelevantsController < ApplicationController
        before_action :set_relevant, only: [:show, :update, :destroy]

        # GET /relevants
        def index
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_relevant
        end

        # Only allow a list of trusted parameters through.
        def relevant_params
        end
    end
end

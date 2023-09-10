=begin

Copyright (c) 2020, all rights reserved.

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
    class String::DiscussionsController < CloudObject::DiscussionsController
        def create
            set_string
            return respond_with_not_found unless @string

            discussion = String::Discussion.new(
                cloud_object_discussion_params.merge({
                    user_creator: current_user,
                    cloud_object: @string,
                    reference_module_bucket_string: "#{@string.reference_module_bucket}-#{@string.label}"
                })
            )

            if discussion.save
                respond_with_successful(discussion.show(current_user))
            else
                respond_with_error(discussion.errors.full_messages.to_sentence)
            end
        end

        private

        def cloud_object_discussion_params
            params.require(:string_discussion).permit(
                :content,
                :cloud_babe_discussions_id,
                :reference_module_bucket_string
            )
        end

        def set_string
            @string = String.where(
                "reference_module_bucket like ?", "#{Rails.configuration.lesli_settings["instance"]}%"
            ).find_by(
                id: params[:string_id]
            )
        end

        def set_cloud_object_discussion
            set_string
            return unless @string

            @cloud_object_discussion = @string.discussions.where(
                "reference_module_bucket_string like ?", "#{Rails.configuration.lesli_settings["instance"]}%"
            ).find_by(
                id: params[:id]
            )
        end
    end
end

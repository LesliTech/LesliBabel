require_dependency "cloud_babel/application_controller"

module CloudBabel
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Controller for the *discussions* core entities. It inherits all its functionality
    from the *CloudObject::DiscussionsController* class
=end
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
                "reference_module_bucket like ?", "#{LC::System::Info.revision[:instance]}%"
            ).find_by(
                id: params[:string_id]
            )
        end

        def set_cloud_object_discussion
            set_string
            return unless @string

            @cloud_object_discussion = @string.discussions.where(
                "reference_module_bucket_string like ?", "#{LC::System::Info.revision[:instance]}%"
            ).find_by(
                id: params[:id]
            )
        end
    end
end

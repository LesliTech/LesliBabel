module LesliBabel
    class String::Discussion < CloudObject::Discussion
        belongs_to :cloud_object, class_name: "String", foreign_key: "cloud_babel_strings_id"
        belongs_to :parent, class_name: "Discussion", optional: true
        has_many :children, class_name: "Discussion", foreign_key: "parent_id"

        def self.list(current_user, cloud_id)
            
            discussions = self.joins(
                "inner join cloud_babel_strings CO on cloud_babel_string_discussions.cloud_babel_strings_id = CO.id"
            ).joins(
                "inner join users U on cloud_babel_string_discussions.users_id = U.id"
            ).joins(
                "inner join user_details UD on UD.users_id = U.id"
            ).select(
                "cloud_babel_string_discussions.id",
                "cloud_babel_string_discussions.users_id",
                "cloud_babel_string_discussions.content",
                "cloud_babel_string_discussions.created_at",
                "cloud_babel_string_discussions.cloud_babel_string_discussions_id",
                "U.email",
                "CONCAT(UD.first_name, ' ', UD.last_name) as user_name"
            )
            .where("CO.id = #{cloud_id}")
            .where("CO.reference_module_bucket LIKE ?", "#{Rails.configuration.lesli_settings["instance"]}%")
            .order(id: :asc)
            .map { |discussion| 
                discussion_attributes = discussion.attributes
                discussion_attributes["created_at_raw"] = discussion_attributes["created_at"]
                discussion_attributes["editable"] = discussion.is_editable_by?(current_user)
                discussion_attributes["created_at"] = LC::Date.to_string_datetime(discussion_attributes["created_at"])
                discussion_attributes
            }

            data = {}
            root_discussions = []

            # Add all responses to that discussion
            discussions.each do |discussion|
                discussion_data = {
                    data: discussion,
                    responses: []
                }
                data[discussion["id"]] = discussion_data

                if discussion["cloud_babel_string_discussions_id"].present?
                    parent_discussion = data[discussion["cloud_babel_string_discussions_id"]]
                    if parent_discussion[:data]["cloud_babel_string_discussions_id"].present?
                        discussion["response_to"] = parent_discussion[:data]["email"]
                    end
                    parent_discussion[:responses].push(discussion["id"])
                else
                    root_discussions.push(discussion_data)
                end
            end

            # Nest the responses to root discussions. A root discussion is any comment that is not a response to another comment
            root_discussions.each do |discussion|
                responses = []
                self.nest_responses(data, discussion, responses)
                discussion[:responses] = responses
            end

            # revert the root discussions so the most recent comments appear in the top
            root_discussions.reverse
        end
    end
end

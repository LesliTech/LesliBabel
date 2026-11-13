=begin

Lesli

Copyright (c) 2025, Lesli Technologies, S. A.

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

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

module LesliBabel
    class TranslationsController < ApplicationController
        before_action :authorize_web_deploy!, only: :deploy

        def deploy
            result = begin
                TranslationDeployService.call
            rescue StandardError => exception
                return respond_with_deploy_error(exception.message)
            end
            errors = result.fetch(:errors)

            return respond_with_deploy_error(errors.join("; "), errors) if errors.any?

            respond_with_lesli(
                turbo: stream_notification_success("Translations deployed successfully."),
                json: {
                    message: "Translations deployed successfully.",
                    files: result.fetch(:files)
                },
                redirect: labels_path
            )
        end

        private

        # Web deploy is enabled outside production by default. Applications may
        # explicitly authorize it in another environment through Lesli config.
        def authorize_web_deploy!
            return if Lesli.config.babel.fetch(:allow_web_deploy, !Rails.env.production?)

            respond_with_lesli(
                turbo: stream_notification_danger("Web translation deploy is disabled."),
                json: { message: "Web translation deploy is disabled." },
                redirect: labels_path,
                status: :forbidden
            )
        end

        def respond_with_deploy_error(message, errors = [message])
            respond_with_lesli(
                turbo: stream_notification_danger(message),
                json: { message: message, errors: errors },
                redirect: labels_path,
                status: :unprocessable_content
            )
        end
    end
end

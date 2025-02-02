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
    class TranslationsController < ApplicationController
        before_action :set_translation, only: []

        # GET /translations
        def index
            @translations = respond_as_pagination(StringService.new(current_user, query).index(params))
        end

        # GET /translations/1
        def show
            @string = StringService.new(current_user, query).show(params.dig(:id))
        end

        def clean
            respond_with_successful()
        end

        def deploy
            #TranslationsService.clean
            DeployRailsService.new(current_user, query).build
            #TranslationsService.restart_server
            respond_with_successful
        end

        def renovate
            result = TranslationsSynchronizationService.remote_sync
            respond_with_successful if result.success?
            respond_with_error if not result.success?
        end

        def sync
            result = TranslationsSynchronizationService.remote_sync true
            respond_with_successful if result.success?
            respond_with_error if not result.success?
        end

        def download

            engine = params[:engine]
            platform = params[:platform]

            translations_result = TranslationsMiddlemanService.build(engine) if platform == "middleman"
            translations_result = TranslationsAndroidService.build(engine) if platform == "android"
            translations_result = TranslationsFlutterService.build(engine) if platform == "flutter"
            translations_result = TranslationsIosService.build(engine) if platform == "ios"
            translations_result = TranslationsJsService.build() if platform == "js"

            return respond_with_error if translations_result.blank?

            zip_file = "#{platform}-#{engine}-translations.zip"

            LC::System::IO.zip(zip_file, translations_result.payload)

            redirect_to "/tmp/#{zip_file}"

        end


        private

        # Use callbacks to share common setup or constraints between actions.
        def set_translation
            @translation = Translation.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_params
            params.fetch(:translation, {})
        end

    end
end

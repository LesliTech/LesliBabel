=begin

Lesli

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

module CloudBabel
    class TranslationsController < ApplicationController
        before_action :set_translation, only: []

        # GET /translations
        def index
            #@translations = Translation.all
        end

        # GET /translations/1
        def show
        end

        # GET /translations/new
        def new
            @translation = Translation.new
        end

        # GET /translations/1/edit
        def edit
        end

        # POST /translations
        def create
            @translation = Translation.new(translation_params)

            if @translation.save
                redirect_to @translation, notice: "Translation was successfully created."
            else
                render :new
            end
        end

        # PATCH/PUT /translations/1
        def update
            if @translation.update(translation_params)
                redirect_to @translation, notice: "Translation was successfully updated."
            else
                render :edit
            end
        end

        # DELETE /translations/1
        def destroy
            @translation.destroy
            redirect_to translations_url, notice: "Translation was successfully destroyed."
        end

        def options
            respond_with_successful({
                locales_available: Rails.application.config.lesli_settings["configuration"]["locales_available"]
            })
        end

        def clean
            responseWithSuccessful()
        end

        def deploy
            TranslationsService.clean
            TranslationsRailsService.build
            TranslationsService.restart_server
            respond_with_successful
        end

        def synchronization
            result = TranslationsSynchronizationService.remote_sync
            respond_with_successful if result.success?
            respond_with_error if not result.success?
        end

        def download

            engine = params[:engine_id]
            platform = params[:platform]

            translations_result = TranslationsAndroidService.build(engine) if platform == "android"
            translations_result = TranslationsIosService.build(engine) if platform == "ios"

            LC::System::IO.zip("translations.zip", translations_result.payload)

            redirect_to "/tmp/translations.zip"

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

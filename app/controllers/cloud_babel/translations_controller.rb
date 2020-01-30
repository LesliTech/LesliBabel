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

@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end

require_dependency "cloud_babel/application_controller"

module CloudBabel
    class TranslationsController < ApplicationController
        before_action :set_translation, only: []

        # GET /translations
        def index
            @translations = Translation.all
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
                redirect_to @translation, notice: 'Translation was successfully created.'
            else
                render :new
            end
        end

        # PATCH/PUT /translations/1
        def update
            if @translation.update(translation_params)
                redirect_to @translation, notice: 'Translation was successfully updated.'
            else
                render :edit
            end
        end

        # DELETE /translations/1
        def destroy
            @translation.destroy
            redirect_to translations_url, notice: 'Translation was successfully destroyed.'
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

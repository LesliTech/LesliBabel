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

        def synchronization
            host = "https://server.raven.dev.gt"
            host = "http://localhost:8888"

            # get last sync data
            response = Faraday.get("#{host}/api/bucket/cloud-babel-dl/documents")
            response = JSON.parse(response.body)
            response = response['data']['rows'][0]


            # if first time sync
            response = JSON.parse({modules: [], buckets: [], strings: [] }.to_json) if response.blank?


            # add new modules
            response['modules'].each do |babel_module|
                CloudBabel::Translation::Module
                .create_with(created_at: babel_module['created_at'])
                .find_or_create_by({ name: babel_module['name'] })
            end

            # working with buckets
            babel_reference_modules = {}
            response['buckets'].each do |babel_bucket|

                # reference to modules that buckets belongs to
                if babel_reference_modules[babel_bucket['reference_module']].blank?
                    babel_reference_modules[babel_bucket['reference_module']] = 
                    CloudBabel::Translation::Module.find_by(name: babel_bucket['reference_module'])
                end

                # add new bucket
                CloudBabel::Translation::Bucket
                .create_with({
                    created_at: babel_bucket['created_at'],
                    module: babel_reference_modules[babel_bucket['reference_module']]
                }).find_or_create_by({
                    name: babel_bucket['name'], 
                    reference_module: babel_bucket['reference_module'] 
                })

            end

            # working with strings
            babel_reference_buckets = {}
            response['strings'].each do |babel_string|

                # reference to modules that buckets belongs to
                if babel_reference_buckets[babel_string['reference_bucket']].blank?
                    babel_reference_buckets[babel_string['reference_bucket']] = 
                    CloudBabel::Translation::Bucket.find_by(
                        name: babel_string['reference_bucket'].split('-')[1],
                        reference_module: babel_string['reference_bucket'].split('-')[0]
                    )
                end

                babel_string_reference = "#{babel_reference_buckets[babel_string['reference_bucket']].module.name}-#{babel_reference_buckets[babel_string['reference_bucket']].name}"

                # add new bucket
                CloudBabel::Translation::String
                .create_with({
                    context: babel_string['context'],
                    es: babel_string['es'],
                    en: babel_string['en'],
                    de: babel_string['de'],
                    status: babel_string['status'],
                    created_at: babel_string['created_at'],
                    bucket: babel_reference_buckets[babel_string['reference_bucket']]
                }).find_or_create_by({
                    label: babel_string['label'], 
                    reference_bucket: babel_string_reference
                })

            end

            # get and parse modules
            modules = CloudBabel::Translation::Module.all.map do |babel_module|
                babel_module.as_json
            end

            # get and parse buckets
            buckets = CloudBabel::Translation::Bucket.all.map do |babel_bucket|
                babel_bucket.as_json
            end

            # get and parse strings
            strings = CloudBabel::Translation::String.all.map do |babel_string|
                babel_string.as_json
            end

            # send latest translation to raven
            response = Faraday.post("#{host}/api/bucket/cloud-babel-dl/documents", 
                ({ modules: modules, buckets: buckets, strings: strings }).to_json,
                "Content-Type" => "application/json"
            )
            responseWithSuccessful()
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

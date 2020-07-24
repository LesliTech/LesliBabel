require_dependency "cloud_babel/application_controller"

module CloudBabel
    class Translation::ModulesController < ApplicationController
        #before_action :set_translation_module, only: [:show, :edit, :update, :destroy]

        # GET /translation/modules
        def index
            modules = Translation::Module.where("name is not null").map do |translation_module|
                
                {
                    id: translation_module[:id],
                    name: translation_module[:name],
                    code: translation_module[:name].downcase,
                }
            end
            respond_to do |format|
                format.html { }
                format.json { respond_with_successful(modules) }
            end
        end

        # GET /translation/modules/1
        def show
        end

        # GET /translation/modules/new
        def new
            @translation_module = Translation::Module.new
        end

        # GET /translation/modules/1/edit
        def edit
        end

        # POST /translation/modules
        def create
            @translation_module = Translation::Module.new(translation_module_params)

            if @translation_module.save
                redirect_to @translation_module, notice: 'Module was successfully created.'
            else
                render :new
            end
        end

        # PATCH/PUT /translation/modules/1
        def update
            return respond_with_not_found unless @translation_module

            if @translation_module.update(translation_module_params)
                redirect_to @translation_module, notice: 'Module was successfully updated.'
            else
                render :edit
            end
        end

        # DELETE /translation/modules/1
        def destroy
            return respond_with_not_found unless @translation_module

            @translation_module.destroy
            redirect_to translation_modules_url, notice: 'Module was successfully destroyed.'
        end

        private

        # @return [void]
        # @description Sets the requested translation module based on the current_users's account
        # @example
        #     # Executing this method from a controller action:
        #     set_translation_module
        #     puts @translation_module
        #     # This will either display nil or an instance of Translation::Module
        def set_translation_module
            @translation_module = Translation::Module.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def translation_module_params
            params.fetch(:translation_module, {})
        end
    end
end

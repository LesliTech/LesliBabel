require_dependency "cloud_babel/application_controller"

module CloudBabel
  class Module::DiscussionsController < ApplicationController
    before_action :set_module_discussion, only: [:show, :edit, :update, :destroy]

    # GET /module/discussions
    def index
      @module_discussions = Module::Discussion.all
    end

    # GET /module/discussions/1
    def show
    end

    # GET /module/discussions/new
    def new
      @module_discussion = Module::Discussion.new
    end

    # GET /module/discussions/1/edit
    def edit
    end

    # POST /module/discussions
    def create
      @module_discussion = Module::Discussion.new(module_discussion_params)

      if @module_discussion.save
        redirect_to @module_discussion, notice: 'Discussion was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /module/discussions/1
    def update
      if @module_discussion.update(module_discussion_params)
        redirect_to @module_discussion, notice: 'Discussion was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /module/discussions/1
    def destroy
      @module_discussion.destroy
      redirect_to module_discussions_url, notice: 'Discussion was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_module_discussion
        @module_discussion = Module::Discussion.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def module_discussion_params
        params.fetch(:module_discussion, {})
      end
  end
end

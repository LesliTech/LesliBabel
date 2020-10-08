require_dependency "cloud_babel/application_controller"

module CloudBabel
  class String::DiscussionsController < ApplicationController
    before_action :set_string_discussion, only: [:show, :edit, :update, :destroy]

    # GET /string/discussions
    def index
      @string_discussions = String::Discussion.all
    end

    # GET /string/discussions/1
    def show
    end

    # GET /string/discussions/new
    def new
      @string_discussion = String::Discussion.new
    end

    # GET /string/discussions/1/edit
    def edit
    end

    # POST /string/discussions
    def create
      @string_discussion = String::Discussion.new(string_discussion_params)

      if @string_discussion.save
        redirect_to @string_discussion, notice: 'Discussion was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /string/discussions/1
    def update
      if @string_discussion.update(string_discussion_params)
        redirect_to @string_discussion, notice: 'Discussion was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /string/discussions/1
    def destroy
      @string_discussion.destroy
      redirect_to string_discussions_url, notice: 'Discussion was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_string_discussion
        @string_discussion = String::Discussion.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def string_discussion_params
        params.fetch(:string_discussion, {})
      end
  end
end

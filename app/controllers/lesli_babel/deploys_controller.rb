module LesliBabel
  class DeploysController < Lesli::ApplicationLesliController

    # GET /deploys
    def index
      @deploys = Deploy.all
    end

    # GET /deploys/1
    def show
        LesliBabel::DeployRailsService.new(current_user, query).build
        respond_with_successful()
    end

    # GET /deploys/new
    def new
      @deploy = Deploy.new
    end

    # GET /deploys/1/edit
    def edit
    end

    # POST /deploys
    def create
      @deploy = Deploy.new(deploy_params)

      if @deploy.save
        redirect_to @deploy, notice: "Deploy was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /deploys/1
    def update
      if @deploy.update(deploy_params)
        redirect_to @deploy, notice: "Deploy was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /deploys/1
    def destroy
      @deploy.destroy
      redirect_to deploys_url, notice: "Deploy was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_deploy
      end

      # Only allow a list of trusted parameters through.
      def deploy_params
        params.fetch(:deploy, {})
      end
  end
end

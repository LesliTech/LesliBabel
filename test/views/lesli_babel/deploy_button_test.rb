require "test_helper"

module LesliBabel
    class DeployButtonTest < ActiveSupport::TestCase
        setup do
            @allow_web_deploy = Lesli.config.babel[:allow_web_deploy]
        end

        teardown do
            Lesli.config.babel[:allow_web_deploy] = @allow_web_deploy
        end

        test "confirms and disables the deploy button while submitting" do
            Lesli.config.babel[:allow_web_deploy] = true

            button = deploy_button.at_css("button")

            assert_includes button["data-turbo-confirm"], "official YAML translation files"
            assert_equal "Deploying...", button["data-turbo-submits-with"]
            assert_nil button["disabled"]
        end

        test "indicates when web deploy is disabled" do
            Lesli.config.babel[:allow_web_deploy] = false

            button = deploy_button.at_css("button")

            assert_equal "Web deploy disabled", button.css("span").last.text.strip
            assert_equal "disabled", button["disabled"]
            assert_equal "Web translation deploy is disabled", button["aria-label"]
            assert_nil deploy_button.at_css("form")
        end

        private

        def deploy_button
            html = LesliBabel::DashboardsController.render(
                partial: "lesli_babel/partials/deploy_button",
                layout: false
            )
            Nokogiri::HTML.fragment(html)
        end
    end
end

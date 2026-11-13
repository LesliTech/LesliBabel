require "test_helper"

module LesliBabel
    class ApplicationControllerTest < ActiveSupport::TestCase
        setup do
            @allow_web_deploy = Lesli.config.babel[:allow_web_deploy]
        end

        teardown do
            Lesli.config.babel[:allow_web_deploy] = @allow_web_deploy
        end

        test "exposes the web deploy configuration to controllers and views" do
            controller = LesliBabel::ApplicationController.new

            Lesli.config.babel[:allow_web_deploy] = true
            assert controller.web_deploy_allowed?

            Lesli.config.babel[:allow_web_deploy] = false
            refute controller.web_deploy_allowed?
        end

        test "exposes the Babel locales to controllers and views" do
            original_locales = Lesli.config.babel[:locales]
            Lesli.config.babel[:locales] = { en: "English", es: "Español" }

            assert_equal({ en: "English", es: "Español" }, LesliBabel::ApplicationController.new.babel_locales)
        ensure
            Lesli.config.babel[:locales] = original_locales
        end
    end
end

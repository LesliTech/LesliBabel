require "test_helper"

module LesliBabel
    class EngineTest < ActiveSupport::TestCase
        test "inherits from Rails engine" do
            assert_operator LesliBabel::Engine, :<, Rails::Engine
        end

        test "isolates the LesliBabel namespace" do
            assert_equal "LesliBabel", LesliBabel::Engine.railtie_namespace.name
        end

        test "defines translation management routes" do
            route_names = LesliBabel::Engine.routes.routes.filter_map(&:name)

            assert_includes route_names, "labels"
            assert_includes route_names, "label"
            assert_includes route_names, "module_buckets"
            assert_includes route_names, "deploy_translations"
            assert_includes route_names, "sync_translations"
        end
    end
end

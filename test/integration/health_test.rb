require "test_helper"

module LesliBabel
    class HealthTest < ActionDispatch::IntegrationTest
        test "serves the Rails health endpoint through the mounted engine" do
            get "/babel/up"

            assert_response :success
            assert_equal "text/html; charset=utf-8", response.content_type
        end
    end
end

require 'test_helper'

module CloudBabel
  class DashboardsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @dashboard = cloud_babel_dashboards(:one)
    end

    test "should get index" do
      get dashboards_url
      assert_response :success
    end

    test "should get new" do
      get new_dashboard_url
      assert_response :success
    end

    test "should create dashboard" do
      assert_difference('Dashboard.count') do
        post dashboards_url, params: { dashboard: {  } }
      end

      assert_redirected_to dashboard_url(Dashboard.last)
    end

    test "should show dashboard" do
      get dashboard_url(@dashboard)
      assert_response :success
    end

    test "should get edit" do
      get edit_dashboard_url(@dashboard)
      assert_response :success
    end

    test "should update dashboard" do
      patch dashboard_url(@dashboard), params: { dashboard: {  } }
      assert_redirected_to dashboard_url(@dashboard)
    end

    test "should destroy dashboard" do
      assert_difference('Dashboard.count', -1) do
        delete dashboard_url(@dashboard)
      end

      assert_redirected_to dashboards_url
    end
  end
end

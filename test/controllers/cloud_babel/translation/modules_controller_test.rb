require 'test_helper'

module CloudBabel
  class Translation::ModulesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @translation_module = cloud_babel_translation_modules(:one)
    end

    test "should get index" do
      get translation_modules_url
      assert_response :success
    end

    test "should get new" do
      get new_translation_module_url
      assert_response :success
    end

    test "should create translation_module" do
      assert_difference('Translation::Module.count') do
        post translation_modules_url, params: { translation_module: {  } }
      end

      assert_redirected_to translation_module_url(Translation::Module.last)
    end

    test "should show translation_module" do
      get translation_module_url(@translation_module)
      assert_response :success
    end

    test "should get edit" do
      get edit_translation_module_url(@translation_module)
      assert_response :success
    end

    test "should update translation_module" do
      patch translation_module_url(@translation_module), params: { translation_module: {  } }
      assert_redirected_to translation_module_url(@translation_module)
    end

    test "should destroy translation_module" do
      assert_difference('Translation::Module.count', -1) do
        delete translation_module_url(@translation_module)
      end

      assert_redirected_to translation_modules_url
    end
  end
end

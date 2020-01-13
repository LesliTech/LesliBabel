require 'test_helper'

module CloudBabel
  class Translation::StringsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @translation_string = cloud_babel_translation_strings(:one)
    end

    test "should get index" do
      get translation_strings_url
      assert_response :success
    end

    test "should get new" do
      get new_translation_string_url
      assert_response :success
    end

    test "should create translation_string" do
      assert_difference('Translation::String.count') do
        post translation_strings_url, params: { translation_string: {  } }
      end

      assert_redirected_to translation_string_url(Translation::String.last)
    end

    test "should show translation_string" do
      get translation_string_url(@translation_string)
      assert_response :success
    end

    test "should get edit" do
      get edit_translation_string_url(@translation_string)
      assert_response :success
    end

    test "should update translation_string" do
      patch translation_string_url(@translation_string), params: { translation_string: {  } }
      assert_redirected_to translation_string_url(@translation_string)
    end

    test "should destroy translation_string" do
      assert_difference('Translation::String.count', -1) do
        delete translation_string_url(@translation_string)
      end

      assert_redirected_to translation_strings_url
    end
  end
end

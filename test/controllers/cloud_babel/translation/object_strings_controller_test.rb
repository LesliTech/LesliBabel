require 'test_helper'

module CloudBabel
  class Translation::ObjectStringsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @translation_object_string = cloud_babel_translation_object_strings(:one)
    end

    test "should get index" do
      get translation_object_strings_url
      assert_response :success
    end

    test "should get new" do
      get new_translation_object_string_url
      assert_response :success
    end

    test "should create translation_object_string" do
      assert_difference('Translation::ObjectString.count') do
        post translation_object_strings_url, params: { translation_object_string: {  } }
      end

      assert_redirected_to translation_object_string_url(Translation::ObjectString.last)
    end

    test "should show translation_object_string" do
      get translation_object_string_url(@translation_object_string)
      assert_response :success
    end

    test "should get edit" do
      get edit_translation_object_string_url(@translation_object_string)
      assert_response :success
    end

    test "should update translation_object_string" do
      patch translation_object_string_url(@translation_object_string), params: { translation_object_string: {  } }
      assert_redirected_to translation_object_string_url(@translation_object_string)
    end

    test "should destroy translation_object_string" do
      assert_difference('Translation::ObjectString.count', -1) do
        delete translation_object_string_url(@translation_object_string)
      end

      assert_redirected_to translation_object_strings_url
    end
  end
end

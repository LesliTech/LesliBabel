require 'test_helper'

module CloudBabel
  class TranslationObjectsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @translation_object = cloud_babel_translation_objects(:one)
    end

    test "should get index" do
      get translation_objects_url
      assert_response :success
    end

    test "should get new" do
      get new_translation_object_url
      assert_response :success
    end

    test "should create translation_object" do
      assert_difference('TranslationObject.count') do
        post translation_objects_url, params: { translation_object: {  } }
      end

      assert_redirected_to translation_object_url(TranslationObject.last)
    end

    test "should show translation_object" do
      get translation_object_url(@translation_object)
      assert_response :success
    end

    test "should get edit" do
      get edit_translation_object_url(@translation_object)
      assert_response :success
    end

    test "should update translation_object" do
      patch translation_object_url(@translation_object), params: { translation_object: {  } }
      assert_redirected_to translation_object_url(@translation_object)
    end

    test "should destroy translation_object" do
      assert_difference('TranslationObject.count', -1) do
        delete translation_object_url(@translation_object)
      end

      assert_redirected_to translation_objects_url
    end
  end
end

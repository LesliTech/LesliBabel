require 'test_helper'

module CloudBabel
  class TranslationObjectGroupsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @translation_object_group = cloud_babel_translation_object_groups(:one)
    end

    test "should get index" do
      get translation_object_groups_url
      assert_response :success
    end

    test "should get new" do
      get new_translation_object_group_url
      assert_response :success
    end

    test "should create translation_object_group" do
      assert_difference('TranslationObjectGroup.count') do
        post translation_object_groups_url, params: { translation_object_group: {  } }
      end

      assert_redirected_to translation_object_group_url(TranslationObjectGroup.last)
    end

    test "should show translation_object_group" do
      get translation_object_group_url(@translation_object_group)
      assert_response :success
    end

    test "should get edit" do
      get edit_translation_object_group_url(@translation_object_group)
      assert_response :success
    end

    test "should update translation_object_group" do
      patch translation_object_group_url(@translation_object_group), params: { translation_object_group: {  } }
      assert_redirected_to translation_object_group_url(@translation_object_group)
    end

    test "should destroy translation_object_group" do
      assert_difference('TranslationObjectGroup.count', -1) do
        delete translation_object_group_url(@translation_object_group)
      end

      assert_redirected_to translation_object_groups_url
    end
  end
end

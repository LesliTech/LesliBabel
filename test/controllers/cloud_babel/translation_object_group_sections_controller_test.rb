require 'test_helper'

module CloudBabel
  class TranslationObjectGroupSectionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @translation_object_group_section = cloud_babel_translation_object_group_sections(:one)
    end

    test "should get index" do
      get translation_object_group_sections_url
      assert_response :success
    end

    test "should get new" do
      get new_translation_object_group_section_url
      assert_response :success
    end

    test "should create translation_object_group_section" do
      assert_difference('TranslationObjectGroupSection.count') do
        post translation_object_group_sections_url, params: { translation_object_group_section: {  } }
      end

      assert_redirected_to translation_object_group_section_url(TranslationObjectGroupSection.last)
    end

    test "should show translation_object_group_section" do
      get translation_object_group_section_url(@translation_object_group_section)
      assert_response :success
    end

    test "should get edit" do
      get edit_translation_object_group_section_url(@translation_object_group_section)
      assert_response :success
    end

    test "should update translation_object_group_section" do
      patch translation_object_group_section_url(@translation_object_group_section), params: { translation_object_group_section: {  } }
      assert_redirected_to translation_object_group_section_url(@translation_object_group_section)
    end

    test "should destroy translation_object_group_section" do
      assert_difference('TranslationObjectGroupSection.count', -1) do
        delete translation_object_group_section_url(@translation_object_group_section)
      end

      assert_redirected_to translation_object_group_sections_url
    end
  end
end

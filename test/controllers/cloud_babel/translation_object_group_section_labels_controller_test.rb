require 'test_helper'

module CloudBabel
  class TranslationObjectGroupSectionLabelsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @translation_object_group_section_label = cloud_babel_translation_object_group_section_labels(:one)
    end

    test "should get index" do
      get translation_object_group_section_labels_url
      assert_response :success
    end

    test "should get new" do
      get new_translation_object_group_section_label_url
      assert_response :success
    end

    test "should create translation_object_group_section_label" do
      assert_difference('TranslationObjectGroupSectionLabel.count') do
        post translation_object_group_section_labels_url, params: { translation_object_group_section_label: {  } }
      end

      assert_redirected_to translation_object_group_section_label_url(TranslationObjectGroupSectionLabel.last)
    end

    test "should show translation_object_group_section_label" do
      get translation_object_group_section_label_url(@translation_object_group_section_label)
      assert_response :success
    end

    test "should get edit" do
      get edit_translation_object_group_section_label_url(@translation_object_group_section_label)
      assert_response :success
    end

    test "should update translation_object_group_section_label" do
      patch translation_object_group_section_label_url(@translation_object_group_section_label), params: { translation_object_group_section_label: {  } }
      assert_redirected_to translation_object_group_section_label_url(@translation_object_group_section_label)
    end

    test "should destroy translation_object_group_section_label" do
      assert_difference('TranslationObjectGroupSectionLabel.count', -1) do
        delete translation_object_group_section_label_url(@translation_object_group_section_label)
      end

      assert_redirected_to translation_object_group_section_labels_url
    end
  end
end

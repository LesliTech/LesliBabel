require "application_system_test_case"

module CloudBabel
  class TranslationObjectGroupSectionLabelsTest < ApplicationSystemTestCase
    setup do
      @translation_object_group_section_label = cloud_babel_translation_object_group_section_labels(:one)
    end

    test "visiting the index" do
      visit translation_object_group_section_labels_url
      assert_selector "h1", text: "Translation Object Group Section Labels"
    end

    test "creating a Translation object group section label" do
      visit translation_object_group_section_labels_url
      click_on "New Translation Object Group Section Label"

      click_on "Create Translation object group section label"

      assert_text "Translation object group section label was successfully created"
      click_on "Back"
    end

    test "updating a Translation object group section label" do
      visit translation_object_group_section_labels_url
      click_on "Edit", match: :first

      click_on "Update Translation object group section label"

      assert_text "Translation object group section label was successfully updated"
      click_on "Back"
    end

    test "destroying a Translation object group section label" do
      visit translation_object_group_section_labels_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Translation object group section label was successfully destroyed"
    end
  end
end

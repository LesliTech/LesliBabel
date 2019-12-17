require "application_system_test_case"

module CloudBabel
  class TranslationObjectGroupLabelsTest < ApplicationSystemTestCase
    setup do
      @translation_object_group_label = cloud_babel_translation_object_group_labels(:one)
    end

    test "visiting the index" do
      visit translation_object_group_labels_url
      assert_selector "h1", text: "Translation Object Group Labels"
    end

    test "creating a Translation object group label" do
      visit translation_object_group_labels_url
      click_on "New Translation Object Group Label"

      click_on "Create Translation object group label"

      assert_text "Translation object group label was successfully created"
      click_on "Back"
    end

    test "updating a Translation object group label" do
      visit translation_object_group_labels_url
      click_on "Edit", match: :first

      click_on "Update Translation object group label"

      assert_text "Translation object group label was successfully updated"
      click_on "Back"
    end

    test "destroying a Translation object group label" do
      visit translation_object_group_labels_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Translation object group label was successfully destroyed"
    end
  end
end

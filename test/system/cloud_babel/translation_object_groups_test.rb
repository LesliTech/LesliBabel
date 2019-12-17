require "application_system_test_case"

module CloudBabel
  class TranslationObjectGroupsTest < ApplicationSystemTestCase
    setup do
      @translation_object_group = cloud_babel_translation_object_groups(:one)
    end

    test "visiting the index" do
      visit translation_object_groups_url
      assert_selector "h1", text: "Translation Object Groups"
    end

    test "creating a Translation object group" do
      visit translation_object_groups_url
      click_on "New Translation Object Group"

      click_on "Create Translation object group"

      assert_text "Translation object group was successfully created"
      click_on "Back"
    end

    test "updating a Translation object group" do
      visit translation_object_groups_url
      click_on "Edit", match: :first

      click_on "Update Translation object group"

      assert_text "Translation object group was successfully updated"
      click_on "Back"
    end

    test "destroying a Translation object group" do
      visit translation_object_groups_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Translation object group was successfully destroyed"
    end
  end
end

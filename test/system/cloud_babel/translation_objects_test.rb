require "application_system_test_case"

module CloudBabel
  class TranslationObjectsTest < ApplicationSystemTestCase
    setup do
      @translation_object = cloud_babel_translation_objects(:one)
    end

    test "visiting the index" do
      visit translation_objects_url
      assert_selector "h1", text: "Translation Objects"
    end

    test "creating a Translation object" do
      visit translation_objects_url
      click_on "New Translation Object"

      click_on "Create Translation object"

      assert_text "Translation object was successfully created"
      click_on "Back"
    end

    test "updating a Translation object" do
      visit translation_objects_url
      click_on "Edit", match: :first

      click_on "Update Translation object"

      assert_text "Translation object was successfully updated"
      click_on "Back"
    end

    test "destroying a Translation object" do
      visit translation_objects_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Translation object was successfully destroyed"
    end
  end
end

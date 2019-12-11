require "application_system_test_case"

module CloudBabel
  class TranslationObjectStringsTest < ApplicationSystemTestCase
    setup do
      @translation_object_string = cloud_babel_translation_object_strings(:one)
    end

    test "visiting the index" do
      visit translation_object_strings_url
      assert_selector "h1", text: "Translation Object Strings"
    end

    test "creating a Translation object string" do
      visit translation_object_strings_url
      click_on "New Translation Object String"

      click_on "Create Translation object string"

      assert_text "Translation object string was successfully created"
      click_on "Back"
    end

    test "updating a Translation object string" do
      visit translation_object_strings_url
      click_on "Edit", match: :first

      click_on "Update Translation object string"

      assert_text "Translation object string was successfully updated"
      click_on "Back"
    end

    test "destroying a Translation object string" do
      visit translation_object_strings_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Translation object string was successfully destroyed"
    end
  end
end

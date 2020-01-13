require "application_system_test_case"

module CloudBabel
  class Translation::StringsTest < ApplicationSystemTestCase
    setup do
      @translation_string = cloud_babel_translation_strings(:one)
    end

    test "visiting the index" do
      visit translation_strings_url
      assert_selector "h1", text: "Translation/Strings"
    end

    test "creating a String" do
      visit translation_strings_url
      click_on "New Translation/String"

      click_on "Create String"

      assert_text "String was successfully created"
      click_on "Back"
    end

    test "updating a String" do
      visit translation_strings_url
      click_on "Edit", match: :first

      click_on "Update String"

      assert_text "String was successfully updated"
      click_on "Back"
    end

    test "destroying a String" do
      visit translation_strings_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "String was successfully destroyed"
    end
  end
end

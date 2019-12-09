require "application_system_test_case"

module CloudBabel
  class TranslationsTest < ApplicationSystemTestCase
    setup do
      @translation = cloud_babel_translations(:one)
    end

    test "visiting the index" do
      visit translations_url
      assert_selector "h1", text: "Translations"
    end

    test "creating a Translation" do
      visit translations_url
      click_on "New Translation"

      click_on "Create Translation"

      assert_text "Translation was successfully created"
      click_on "Back"
    end

    test "updating a Translation" do
      visit translations_url
      click_on "Edit", match: :first

      click_on "Update Translation"

      assert_text "Translation was successfully updated"
      click_on "Back"
    end

    test "destroying a Translation" do
      visit translations_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Translation was successfully destroyed"
    end
  end
end

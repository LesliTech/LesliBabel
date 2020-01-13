require "application_system_test_case"

module CloudBabel
  class Translation::ModulesTest < ApplicationSystemTestCase
    setup do
      @translation_module = cloud_babel_translation_modules(:one)
    end

    test "visiting the index" do
      visit translation_modules_url
      assert_selector "h1", text: "Translation/Modules"
    end

    test "creating a Module" do
      visit translation_modules_url
      click_on "New Translation/Module"

      click_on "Create Module"

      assert_text "Module was successfully created"
      click_on "Back"
    end

    test "updating a Module" do
      visit translation_modules_url
      click_on "Edit", match: :first

      click_on "Update Module"

      assert_text "Module was successfully updated"
      click_on "Back"
    end

    test "destroying a Module" do
      visit translation_modules_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Module was successfully destroyed"
    end
  end
end

require "application_system_test_case"

module CloudBabel
  class Translation::ObjectsTest < ApplicationSystemTestCase
    setup do
      @translation_object = cloud_babel_translation_objects(:one)
    end

    test "visiting the index" do
      visit translation_objects_url
      assert_selector "h1", text: "Translation/Objects"
    end

    test "creating a Object" do
      visit translation_objects_url
      click_on "New Translation/Object"

      click_on "Create Object"

      assert_text "Object was successfully created"
      click_on "Back"
    end

    test "updating a Object" do
      visit translation_objects_url
      click_on "Edit", match: :first

      click_on "Update Object"

      assert_text "Object was successfully updated"
      click_on "Back"
    end

    test "destroying a Object" do
      visit translation_objects_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Object was successfully destroyed"
    end
  end
end

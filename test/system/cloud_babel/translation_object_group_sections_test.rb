require "application_system_test_case"

module CloudBabel
  class TranslationObjectGroupSectionsTest < ApplicationSystemTestCase
    setup do
      @translation_object_group_section = cloud_babel_translation_object_group_sections(:one)
    end

    test "visiting the index" do
      visit translation_object_group_sections_url
      assert_selector "h1", text: "Translation Object Group Sections"
    end

    test "creating a Translation object group section" do
      visit translation_object_group_sections_url
      click_on "New Translation Object Group Section"

      click_on "Create Translation object group section"

      assert_text "Translation object group section was successfully created"
      click_on "Back"
    end

    test "updating a Translation object group section" do
      visit translation_object_group_sections_url
      click_on "Edit", match: :first

      click_on "Update Translation object group section"

      assert_text "Translation object group section was successfully updated"
      click_on "Back"
    end

    test "destroying a Translation object group section" do
      visit translation_object_group_sections_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Translation object group section was successfully destroyed"
    end
  end
end

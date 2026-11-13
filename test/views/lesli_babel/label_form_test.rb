require "test_helper"

module LesliBabel
    class LabelFormTest < ActiveSupport::TestCase
        setup do
            @original_locales = Lesli.config.babel[:locales]
            Lesli.config.babel[:locales] = { en: "English", es: "Español" }

            translation_module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_engine")
            bucket = LesliBabel::Bucket.create!(
                code: "labels",
                reference_module: "lesli_babel",
                module: translation_module
            )
            @label = LesliBabel::Label.create!(
                bucket: bucket,
                text: "page_title",
                status: :ok,
                en: "Labels",
                es: "Traducciones",
                fr: "Traductions"
            )
        end

        teardown do
            Lesli.config.babel[:locales] = @original_locales
        end

        test "renders only configured locales and a read-only copyable path" do
            html = rendered_form
            document = Nokogiri::HTML.fragment(html)
            copy_button = document.at_css("button[type='button']")

            assert document.at_css("input[name='label[en]']")
            assert document.at_css("input[name='label[es]']")
            assert_nil document.at_css("input[name='label[fr]']")
            assert_nil document.at_css("input[name='label[path]']")
            assert_equal "lesli_babel.labels.page_title", copy_button.at_css("code").text.strip
            assert_includes html, "navigator.clipboard.writeText"
        end

        private

        def rendered_form
            LesliBabel::LabelsController.render(
                partial: "lesli_babel/labels/form",
                assigns: { label: @label },
                layout: false
            )
        end
    end
end

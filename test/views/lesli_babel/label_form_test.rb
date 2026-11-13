require "test_helper"

module LesliBabel
    class LabelFormTest < ActiveSupport::TestCase
        setup do
            @original_locales = Lesli.config.babel[:locales]
            Lesli.config.babel[:locales] = { en: "English", es: "Español" }

            @translation_module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_engine")
            bucket = LesliBabel::Bucket.create!(
                code: "labels",
                reference_module: "lesli_babel",
                module: @translation_module
            )
            @label = LesliBabel::Label.create!(
                bucket: bucket,
                text: "page_title",
                status: :ok,
                en: "%{count} :records",
                es: "",
                fr: "Traductions"
            )
        end

        teardown do
            Lesli.config.babel[:locales] = @original_locales
        end

        test "renders only configured locales and a read-only copyable path" do
            html = rendered_form
            document = Nokogiri::HTML.fragment(html)

            source = document.at_css("textarea[name='label[en]']")
            missing = document.at_css("textarea[name='label[es]']")

            assert source
            assert missing
            assert_equal "3", source["rows"]
            assert_includes source["class"].split, "!min-h-0"
            assert_nil source["readonly"]
            assert_nil source["disabled"]
            assert_nil document.at_css("textarea[name='label[fr]']")
            context = document.at_css("textarea[name='label[context]']")
            assert context
            assert_equal "3", context["rows"]
            assert_includes context["class"].split, "!min-h-0"
            assert_includes document.text, "Tokens: %{count}, :records"
            assert_includes document.text, "Missing translation"
            assert_equal "Missing translation", missing["placeholder"]
            assert_nil document.at_css("input[name='label[path]']")
            assert_nil document.at_css("legend")
            assert_not_includes document.text, "Label ok"
        end

        test "presents the path in the header and metadata inside the form" do
            html = rendered_show
            document = Nokogiri::HTML.fragment(html)
            metadata = document.at_css("[aria-label='Translation label metadata']")
            form = document.at_css("#lesli-babel-labels-form")

            assert_equal "Page Title", document.at_css("h1").text.strip
            assert_equal "lesli_babel.labels.page_title", document.at_css("code[x-ref='path']").text.strip
            assert_includes html, "navigator.clipboard.writeText"
            assert_equal "OK", metadata.at_css("[data-label-status='ok']").text.strip
            assert_includes metadata["class"].split, "justify-end"
            assert form.at_css("[aria-label='Translation label metadata']")
            assert_includes form.at_css("fieldset")["class"].split, "border-emerald-300"
            save_button = form.at_css("button[type='submit']")
            assert_includes save_button.text, "Save translations"
            assert_nil save_button["data-turbo-submits-with"]
            assert_includes metadata.text.squish, "Module Lesli Babel"
            assert_includes metadata.text.squish, "Bucket Labels"
        end

        test "loads the label editor in a side panel without navigating away from the list" do
            index_html = rendered_index
            index = Nokogiri::HTML.fragment(index_html)
            panel = Nokogiri::HTML.fragment(rendered_panel)
            label_links = index.css("a").select do |link|
                URI.parse(link["href"]).path == "/babel/labels/#{@label.id}"
            end

            assert_not_empty label_links
            assert label_links.all? { |link| link["data-turbo-frame"] == "babel-label-editor" }
            assert label_links.all? { |link| link["class"].split.include?("link") }
            assert_includes index_html, "@click=\"$dispatch(&#39;babel-label-panel&#39;)\""
            assert index.at_css("#babel-label-panel-panel [role='dialog']")
            assert_equal "Select a translation to edit.", index.at_css("turbo-frame#babel-label-editor").text.strip
            assert_equal "Page Title", panel.at_css("h3").text.strip
            assert_nil panel.at_css("code")
            assert_equal "/babel/labels/#{@label.id}", URI.parse(panel.at_css("form")["action"]).path
            assert_nil URI.parse(panel.at_css("form")["action"]).query
        end

        private

        def rendered_form
            LesliBabel::LabelsController.render(
                partial: "lesli_babel/labels/form",
                assigns: { label: @label },
                layout: false
            )
        end

        def rendered_show
            LesliBabel::LabelsController.render(
                template: "lesli_babel/labels/show",
                assigns: { label: @label, module: @translation_module },
                layout: false
            )
        end

        def rendered_index
            record = LabelService.new(nil).builder.find(@label.id)

            LesliBabel::LabelsController.render(
                template: "lesli_babel/labels/index",
                assigns: {
                    labels: { records: [record] },
                    module: @translation_module,
                    missing_translations: true,
                    missing_locale: "Español"
                },
                layout: false
            )
        end

        def rendered_panel
            LesliBabel::LabelsController.render(
                template: "lesli_babel/labels/panel",
                assigns: { label: @label },
                layout: false
            )
        end
    end
end

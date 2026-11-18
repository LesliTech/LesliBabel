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

        test "renders only configured locales as textareas" do
            document = Nokogiri::HTML.fragment(rendered_form)

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
        end

        test "renders a long translation in a textarea" do
            translation = Array.new(
                10,
                "A long translation with enough content for several lines."
            ).join(" ")
            @label.update!(en: translation)

            document = Nokogiri::HTML.fragment(rendered_form)
            textarea = document.at_css("textarea[name='label[en]']")

            assert textarea
            assert_equal translation, textarea.text.strip
            assert_equal "3", textarea["rows"]
        end

        test "identifies an empty translation as pending" do
            document = Nokogiri::HTML.fragment(rendered_form)
            missing = document.at_css("textarea[name='label[es]']")
            missing_languages = document.at_css("[aria-label='Missing translation languages']")

            assert_includes document.text, "Missing translation"
            assert_equal "Missing translation", missing["placeholder"]
            assert_includes missing_languages.text, "Español"
            assert_not_includes missing_languages.text, "English"
        end

        test "shows interpolation tokens without changing their values" do
            document = Nokogiri::HTML.fragment(rendered_form)

            assert_equal "%{count} :records", document.at_css("textarea[name='label[en]']").text.strip
            assert_includes document.text, "Tokens: %{count}, :records"
        end

        test "presents the path as read-only and copyable" do
            html = rendered_show
            document = Nokogiri::HTML.fragment(html)

            assert_equal "lesli_babel.labels.page_title", document.at_css("code[x-ref='path']").text.strip
            assert_includes html, "navigator.clipboard.writeText"
            assert_nil document.at_css("input[name='label[path]']")
        end

        test "renders only supported editorial statuses" do
            document = Nokogiri::HTML.fragment(rendered_form)

            assert_nil document.at_css("select[name='label[status]'] option[value='disabled']")
            assert_nil document.at_css("legend")
            assert_not_includes document.text, "Label ok"
        end

        test "warns when a label needs context but has no context" do
            @label.update!(status: :need_context, context: "")

            document = Nokogiri::HTML.fragment(rendered_form)
            warning = document.at_css("[role='alert']")

            assert_includes warning.text, "Context required"
            assert_includes warning.text, "no context has been provided"

            @label.update!(context: "Shown in the main navigation")

            document = Nokogiri::HTML.fragment(rendered_form)
            assert_nil document.at_css("[role='alert']")
        end

        test "presents label metadata inside the form" do
            html = rendered_show
            document = Nokogiri::HTML.fragment(html)
            metadata = document.at_css("[aria-label='Translation label metadata']")
            form = document.at_css("#lesli-babel-labels-form")

            assert_equal "Page Title", document.at_css("h1").text.strip
            assert_equal "OK", metadata.at_css("[data-label-status='ok']").text.strip
            assert_includes metadata["class"].split, "justify-end"
            assert form.at_css("[aria-label='Translation label metadata']")
            assert_includes form.at_css("fieldset")["class"].split, "border-success-300"
            save_button = form.at_css("button[type='submit']")
            assert_includes save_button.text, "Save translations"
            assert_nil save_button["data-turbo-submits-with"]
            assert_includes metadata.text.squish, "Module Lesli Babel"
            assert_includes metadata.text.squish, "Bucket Labels"
            assert_includes document.text, "Delete translation"
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
            delete_form = panel.css("form").find { |form| form["method"] == "post" && form.at_css("input[name='_method'][value='delete']") }
            delete_button = delete_form.at_css("button")
            assert_equal "/babel/labels/#{@label.id}", URI.parse(delete_form["action"]).path
            assert_equal "_top", delete_button["data-turbo-frame"]
            assert_includes delete_button["data-turbo-confirm"], "cannot be undone"
            assert_includes delete_button.text, "Delete translation"
        end

        test "renders responsive module navigation and contains long table content" do
            document = Nokogiri::HTML.fragment(rendered_index)
            mobile_navigation = document.at_css("details.lesli-navigation-sidebar-mobile")
            desktop_navigation = document.at_css("nav.lesli-navigation-sidebar-desktop")
            assert mobile_navigation, "Expected the shared mobile navigation"
            assert desktop_navigation, "Expected the shared desktop navigation"
            summary = mobile_navigation.at_css("summary")
            label_link = document.css("a").find { |link| link["href"] == "/babel/labels/#{@label.id}" }
            path_button = document.css("button").find do |button|
                button.text.include?(@label.translation_path)
            end

            assert summary, "Expected an accessible mobile disclosure"
            navigation_label = I18n.t("lesli_babel.navigation.modules")
            assert_equal navigation_label, mobile_navigation.at_css("nav")["aria-label"]
            assert_equal navigation_label, desktop_navigation["aria-label"]
            assert_includes summary["class"].split, "lesli-navigation-sidebar-summary"
            assert_includes summary["aria-label"], "Lesli Babel"
            [mobile_navigation, desktop_navigation].each do |navigation|
                links = navigation.css("a")
                assert_not_empty links
                assert links.all? { |link| link["class"].split.include?("lesli-navigation-sidebar-link") }
                assert navigation.at_css("a[aria-current='page']")
            end
            assert_includes label_link["class"].split, "break-all"
            assert_includes path_button["class"].split, "w-full"
            assert_includes path_button["class"].split, "min-w-0"
            assert document.at_css("div.flex-1.overflow-hidden")
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

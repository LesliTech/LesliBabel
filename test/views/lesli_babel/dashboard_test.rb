require "test_helper"

module LesliBabel
    class DashboardTest < ActiveSupport::TestCase
        test "renders the dashboard when no locales are configured" do
            document = render_dashboard(stats_with(locales: []))

            assert_equal "Translations dashboard", document.at_css("h1").text.strip
            assert_includes document.text, "Tracking 0 labels across 0 locales with 0% global coverage."
            assert_empty locale_section(document).css("a")
        end

        test "renders responsive and accessible locale cards" do
            locale = {
                code: :en,
                name: "English",
                completed: 8,
                missing: 2,
                coverage: 80
            }
            document = render_dashboard(stats_with(locales: [locale]))
            attention_classes = attention_section(document)["class"].split
            grid = locale_section(document).at_css("div.grid")
            card = grid.at_css("a")
            progress = card.at_css("[role='progressbar']")

            assert_includes attention_classes, "sm:grid-cols-2"
            assert_includes attention_classes, "lg:grid-cols-3"
            assert_includes grid["class"].split, "sm:grid-cols-2"
            assert_includes grid["class"].split, "lg:grid-cols-3"

            assert_includes card["class"].split, "focus-visible:ring-2"
            assert_equal "English: 80% coverage, 2 pending translations. View pending translations.", card["aria-label"]
            assert_equal "English coverage", progress["aria-label"]
            assert_equal "80", progress["aria-valuenow"]
            assert_equal "80% coverage", progress["aria-valuetext"]
            assert_includes card.text, "Translated"
            assert_includes card.text, "Pending"
            assert_includes card.text, "80%"
        end

        private

        def render_dashboard(stats)
            html = LesliBabel::DashboardsController.render(
                template: "lesli_babel/dashboards/show",
                assigns: { stats: stats },
                layout: false
            )

            Nokogiri::HTML.fragment(html)
        end

        def stats_with(locales:)
            {
                total_labels: 0,
                locales: locales,
                summary: {
                    configured_locales: locales.size,
                    pending_translations: locales.sum { |locale| locale[:missing] },
                    coverage: locales.empty? ? 0 : 80
                },
                attention: {
                    need_translation: 0,
                    need_help: 0,
                    need_context: 0
                }
            }
        end

        def attention_section(document)
            document.at_css("section[aria-label='Labels requiring attention']")
        end

        def locale_section(document)
            document.at_css("section[aria-label='Translation status by locale']")
        end
    end
end

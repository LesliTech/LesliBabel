require "test_helper"

module LesliBabel
    class TailwindBundleTest < ActiveSupport::TestCase
        test "builds utilities without preflight or shared component selectors" do
            source = engine_file("source/tailwind/application.css")
            bundle = engine_file("app/assets/stylesheets/lesli_babel/application.css")

            assert_includes source, 'tailwindcss/utilities.css'
            assert_not_includes source, "preflight"
            assert_not_includes source, '@import "tailwindcss"'
            assert_no_match(/\.lesli-(button|header|table|toolbar)\b/, bundle)
            assert_no_match(/^\s*(html|body|button|input|a|table)\s*\{/m, bundle)
        end

        private

        def engine_file(path)
            LesliBabel::Engine.root.join(path).read
        end
    end
end

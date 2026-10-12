require "test_helper"

module LesliBabel
    class LabelTest < LesliTesting::ModelTester
        test "belongs to a bucket" do
            reflection = LesliBabel::Label.reflect_on_association(:bucket)

            assert_not_nil reflection
            assert_equal :belongs_to, reflection.macro
            assert_equal LesliBabel::Bucket, reflection.klass
        end

        test "defines translation workflow statuses" do
            assert_equal %w[ok disabled need_help need_context need_translation], LesliBabel::Label.statuses.keys
        end

        test "maps workflow statuses to display categories" do
            assert_equal "warning", LesliBabel::Label.new(status: :need_help).category
            assert_equal "info", LesliBabel::Label.new(status: :need_context).category
            assert_equal "danger", LesliBabel::Label.new(status: :need_translation).category
            assert_equal "ok", LesliBabel::Label.new(status: :ok).category
            assert_equal "ok", LesliBabel::Label.new(status: :disabled).category
        end

        test "normalizes text and records its bucket reference before creation" do
            translation_module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_engine")
            bucket = LesliBabel::Bucket.create!(
                code: "labels",
                reference_module: "lesli_babel",
                module: translation_module
            )

            label = LesliBabel::Label.create!(
                bucket: bucket,
                prefix: :button,
                text: "Save Changes!"
            )

            assert_equal "button_save_changes", label.text
            assert_equal "lesli_babel-labels", label.reference_bucket
        end
    end
end

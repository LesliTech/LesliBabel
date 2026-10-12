require "test_helper"

module LesliBabel
    class ModuleTest < LesliTesting::ModelTester
        test "requires a platform" do
            translation_module = LesliBabel::Module.new(code: "example")

            assert_not translation_module.valid?
            assert_includes translation_module.errors[:platform], "can't be blank"
        end

        test "has buckets and labels through buckets" do
            buckets = LesliBabel::Module.reflect_on_association(:buckets)
            labels = LesliBabel::Module.reflect_on_association(:labels)

            assert_equal :has_many, buckets&.macro
            assert_equal LesliBabel::Bucket, buckets&.klass
            assert_equal :has_many, labels&.macro
            assert_equal :buckets, labels&.options&.fetch(:through)
            assert_equal LesliBabel::Label, labels&.klass
        end

        test "normalizes third-party module codes before creation" do
            translation_module = LesliBabel::Module.create!(
                code: "Cloud-House_Test App",
                platform: "third_party"
            )

            assert_equal "CloudHouseTestApp", translation_module.code
        end

        test "preserves Lesli engine module codes" do
            translation_module = LesliBabel::Module.create!(
                code: "lesli_babel",
                platform: "lesli_engine"
            )

            assert_equal "lesli_babel", translation_module.code
        end
    end
end

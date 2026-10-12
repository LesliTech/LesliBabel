require "test_helper"

module LesliBabel
    class BucketTest < ActiveSupport::TestCase
        test "belongs to a translation module" do
            reflection = LesliBabel::Bucket.reflect_on_association(:module)

            assert_not_nil reflection
            assert_equal :belongs_to, reflection.macro
            assert_equal LesliBabel::Module, reflection.klass
        end

        test "has many labels" do
            reflection = LesliBabel::Bucket.reflect_on_association(:labels)

            assert_not_nil reflection
            assert_equal :has_many, reflection.macro
            assert_equal LesliBabel::Label, reflection.klass
        end
    end
end

require "test_helper"

module LesliBabel
    class ApplicationRecordTest < ActiveSupport::TestCase
        test "inherits from the shared Lesli record" do
            assert_operator LesliBabel::ApplicationRecord, :<, Lesli::ApplicationLesliRecord
        end

        test "is abstract" do
            assert_predicate LesliBabel::ApplicationRecord, :abstract_class?
        end
    end
end

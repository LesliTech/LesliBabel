require "test_helper"

module LesliBabel
    class ApplicationRecordTest < ActiveSupport::TestCase
        test "inherits from the Lesli record without soft deletion" do
            assert_operator LesliBabel::ApplicationRecord, :<, Lesli::ApplicationRecord
            assert_not_respond_to LesliBabel::ApplicationRecord, :with_deleted
        end

        test "is abstract" do
            assert_predicate LesliBabel::ApplicationRecord, :abstract_class?
        end
    end
end

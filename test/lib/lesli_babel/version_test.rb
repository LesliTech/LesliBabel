require "test_helper"

module LesliBabel
    class VersionTest < ActiveSupport::TestCase
        test "has a version number" do
            assert_predicate LesliBabel::VERSION, :present?
        end

        test "has a build number" do
            assert_predicate LesliBabel::BUILD, :present?
        end
    end
end

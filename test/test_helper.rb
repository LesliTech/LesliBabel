ENV["RAILS_ENV"] ||= "test"

require "lesli_testing"

LesliTesting.engine("LesliBabel", {
    coverage_min_coverage: 10
})

require_relative "dummy/config/environment"
require "rails/test_help"

ENV["RAILS_ENV"] ||= "test"

require "lesli_testing"

LesliTesting.engine("LesliBabel", {
    coverage_min_coverage: 10,
    coverage_profile: "engine"
})

require_relative "dummy/config/environment"

ActiveRecord::Migrator.migrations_paths = [File.expand_path("dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)

require "rails/test_help"

if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
    fixture_path = File.expand_path("fixtures", __dir__)

    ActiveSupport::TestCase.fixture_paths = [fixture_path]
    ActionDispatch::IntegrationTest.fixture_paths = [fixture_path]
    ActiveSupport::TestCase.file_fixture_path = File.join(fixture_path, "files")
    ActiveSupport::TestCase.fixtures :all
end

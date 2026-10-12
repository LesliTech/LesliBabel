require "test_helper"

module LesliBabel
    class LabelServiceTest < ActiveSupport::TestCase
        setup do
            @module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_engine")
            @bucket = Bucket.create!(code: "labels", reference_module: "lesli_babel", module_id: @module.id)
            @label = Label.create!(bucket: @bucket, text: "Page title", status: :ok, en: "Labels")
        end

        test "find exposes an existing label as the service result" do
            service = LabelService.new.find(@label.id)

            assert_predicate service, :found?
            assert_equal @label, service.result
        end

        test "builder filters labels by module and bucket" do
            other_module = LesliBabel::Module.create!(code: "other", platform: "lesli_engine")
            other_bucket = Bucket.create!(code: "shared", reference_module: "other", module_id: other_module.id)
            other_label = Label.create!(bucket: other_bucket, text: "Other label", status: :ok)

            service = LabelService.new

            assert_equal [@label.id], service.builder(modules_id: [@module.id]).reselect(:id).pluck(:id)
            assert_equal [other_label.id], service.builder(buckets_id: [other_bucket.id]).reselect(:id).pluck(:id)
        end
    end
end

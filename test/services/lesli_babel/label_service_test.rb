require "test_helper"

module LesliBabel
    class LabelServiceTest < ActiveSupport::TestCase
        setup do
            @original_locales = Lesli.config.babel[:locales]
            Lesli.config.babel[:locales] = { en: "English", es: "Español" }
            @module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_engine")
            @bucket = Bucket.create!(code: "labels", reference_module: "lesli_babel", module_id: @module.id)
            @label = Label.create!(bucket: @bucket, text: "Page title", status: :ok, en: "Labels")
        end

        teardown do
            Lesli.config.babel[:locales] = @original_locales
        end

        test "find exposes an existing label as the service result" do
            service = LabelService.new(nil).find(@label.id)

            assert_predicate service, :found?
            assert_equal @label, service.result
        end

        test "builder filters labels by module and bucket" do
            other_module = LesliBabel::Module.create!(code: "other", platform: "lesli_engine")
            other_bucket = Bucket.create!(code: "shared", reference_module: "other", module_id: other_module.id)
            other_label = Label.create!(bucket: other_bucket, text: "Other label", status: :ok)

            service = LabelService.new(nil)

            assert_equal [@label.id], service.builder(modules_id: [@module.id]).reselect(:id).pluck(:id)
            assert_equal [other_label.id], service.builder(buckets_id: [other_bucket.id]).reselect(:id).pluck(:id)
        end

        test "index filters pending translations for a configured locale" do
            missing = Label.create!(bucket: @bucket, text: "Missing", status: :ok, en: nil)
            blank = Label.create!(bucket: @bucket, text: "Blank", status: :need_translation, en: "")
            Label.create!(bucket: @bucket, text: "Disabled", status: :disabled, en: nil)

            query = { pagination: { page: 1, perPage: 100 } }
            records = LabelService.new(nil, query).index(locale: "en", missing: "true")

            assert_equal [blank.id, missing.id].sort, records.pluck(:id).sort
        end
    end
end

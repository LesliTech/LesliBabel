require "test_helper"

module LesliBabel
    class DatabaseStructureTest < ActiveSupport::TestCase
        test "requires the portable translation hierarchy" do
            module_columns = LesliBabel::Module.columns_hash
            bucket_columns = Bucket.columns_hash
            label_columns = Label.columns_hash

            refute module_columns.fetch("code").null
            refute module_columns.fetch("platform").null
            refute bucket_columns.fetch("module_id").null
            refute bucket_columns.fetch("code").null
            refute bucket_columns.fetch("reference_module").null
            refute label_columns.fetch("bucket_id").null
            refute label_columns.fetch("text").null
            refute label_columns.fetch("reference_bucket").null
        end

        test "stores context and translations as text" do
            columns = Label.columns_hash

            assert_equal :text, columns.fetch("context").type
            %w[es en de fr nl pl pt it tr ro bg uk sr hr].each do |locale|
                assert_equal :text, columns.fetch(locale).type
            end
        end

        test "defines unique indexes for active translation paths" do
            connection = ActiveRecord::Base.connection
            module_index = connection.indexes("lesli_babel_modules").find do |index|
                index.name == "idx_babel_modules_unique_active_platform_code"
            end
            bucket_index = connection.indexes("lesli_babel_buckets").find do |index|
                index.name == "idx_babel_buckets_unique_active_module_code"
            end
            label_index = connection.indexes("lesli_babel_labels").find do |index|
                index.name == "idx_babel_labels_unique_active_bucket_text"
            end

            [module_index, bucket_index, label_index].each do |index|
                assert_predicate index, :unique
                assert_equal "deleted_at IS NULL", index.where
            end
        end

        test "accepts translation values longer than a varchar" do
            translation_module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_engine")
            bucket = Bucket.create!(
                code: "database",
                reference_module: "lesli_babel",
                module: translation_module
            )
            translation = "a" * 1_000

            label = Label.create!(bucket: bucket, text: "message_long", en: translation)

            assert_equal translation, label.reload.en
        end
    end
end

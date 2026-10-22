require "test_helper"

module LesliBabel
    class TranslationServiceTest < ActiveSupport::TestCase
        setup do
            Rails.cache.clear
            account = Struct.new(:id).new(1)
            @current_user = Struct.new(:account).new(account)

            translation_module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_engine")
            bucket = Bucket.create!(code: "labels", reference_module: "lesli_babel", module_id: translation_module.id)

            Label.create!(bucket: bucket, text: "Translated", status: :ok, en: "Translated", es: "Traducido")
            Label.create!(bucket: bucket, text: "Pending", status: :need_translation, en: "Pending")
            Label.create!(bucket: bucket, text: "Blank", status: :need_translation, en: "", es: "")
        end

        test "stats counts registered labels and translations per configured locale" do
            stats = TranslationService.new(@current_user).stats
            translations = stats[:total_strings_translations].index_by { |locale| locale[:code] }

            assert_equal 3, stats[:total_strings]
            assert_equal 2, translations[:en][:total]
            assert_equal 1, translations[:es][:total]
            assert_equal 0, stats[:total_strings_waiting_for_help]
            assert_equal 0, stats[:total_strings_waiting_for_translation]
        end

    end
end

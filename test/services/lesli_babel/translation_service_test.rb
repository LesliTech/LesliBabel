require "test_helper"

module LesliBabel
    class TranslationServiceTest < ActiveSupport::TestCase
        setup do
            @original_locales = Lesli.config.babel[:locales]
            Lesli.config.babel[:locales] = { en: "English", es: "Español" }
            account = Struct.new(:id).new(1)
            @current_user = Struct.new(:account).new(account)

            translation_module = LesliBabel::Module.create!(code: "lesli_babel", platform: "lesli_engine")
            bucket = Bucket.create!(code: "labels", reference_module: "lesli_babel", module_id: translation_module.id)

            Label.create!(bucket: bucket, text: "Translated", status: :ok, en: "Translated", es: "Traducido")
            Label.create!(bucket: bucket, text: "Pending", status: :need_translation, en: "Pending")
            Label.create!(bucket: bucket, text: "Blank", status: :need_translation, en: "", es: "")
            Label.create!(bucket: bucket, text: "Help", status: :need_help, en: "Help")
            Label.create!(bucket: bucket, text: "Context", status: :need_context)
            Label.create!(bucket: bucket, text: "Disabled", status: :disabled, en: "", es: "")
        end

        teardown do
            Lesli.config.babel[:locales] = @original_locales
        end

        test "stats returns actionable translation progress" do
            service = TranslationService.new(@current_user)
            stats = service.stats
            locales = stats[:locales].index_by { |locale| locale[:code] }

            assert_not_respond_to service, :deploy
            assert_equal 6, stats[:total_labels]
            assert_equal({ completed: 3, missing: 2, coverage: 60 }, locales[:en].slice(:completed, :missing, :coverage))
            assert_equal({ completed: 1, missing: 4, coverage: 20 }, locales[:es].slice(:completed, :missing, :coverage))
            assert_equal({
                configured_locales: 2,
                pending_translations: 6,
                coverage: 40
            }, stats[:summary])
            assert_equal({
                need_translation: 2,
                need_help: 1,
                need_context: 1
            }, stats[:attention])
        end

        test "coverage is zero when no labels are translatable" do
            Label.update_all(status: :disabled)

            stats = TranslationService.new(@current_user).stats

            stats[:locales].each do |locale|
                assert_equal 0, locale[:completed]
                assert_equal 0, locale[:missing]
                assert_equal 0, locale[:coverage]
            end
            assert_equal 0, stats.dig(:summary, :pending_translations)
            assert_equal 0, stats.dig(:summary, :coverage)
        end
    end
end

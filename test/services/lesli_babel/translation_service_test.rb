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

        test "stats counts every registered label" do
            service = TranslationService.new(@current_user)
            stats = service.stats

            assert_not_respond_to service, :deploy
            assert_equal 6, stats[:total_labels]
        end

        test "stats reports completed missing and coverage for every locale" do
            locales = stats[:locales].index_by { |locale| locale[:code] }

            assert_equal({ completed: 3, missing: 2, coverage: 60 }, locales[:en].slice(:completed, :missing, :coverage))
            assert_equal({ completed: 1, missing: 4, coverage: 20 }, locales[:es].slice(:completed, :missing, :coverage))
        end

        test "stats orders locales from lowest to highest coverage" do
            assert_equal [:es, :en], stats[:locales].pluck(:code)
        end

        test "stats reports the catalog summary" do
            assert_equal({
                configured_locales: 2,
                pending_translations: 6,
                coverage: 40
            }, stats[:summary])
        end

        test "stats counts labels that need translation" do
            assert_equal 2, stats.dig(:attention, :need_translation)
        end

        test "stats counts labels that need help" do
            assert_equal 1, stats.dig(:attention, :need_help)
        end

        test "stats counts labels that need context" do
            assert_equal 1, stats.dig(:attention, :need_context)
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

        private

        def stats
            @stats ||= TranslationService.new(@current_user).stats
        end
    end
end

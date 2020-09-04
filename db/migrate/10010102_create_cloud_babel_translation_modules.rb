class CreateCloudBabelTranslationModules < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_modules do |t|
            t.string :name
            t.string :module_type
            t.timestamps
        end
    end
end

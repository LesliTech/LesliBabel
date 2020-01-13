class CreateCloudBabelTranslations < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translations do |t|
            t.timestamps
        end
    end
end

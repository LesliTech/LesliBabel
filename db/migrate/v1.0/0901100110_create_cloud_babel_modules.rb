class CreateCloudBabelModules < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_modules do |t|
            t.string :name
            t.string :platform
            t.datetime :deleted_at
            t.timestamps
        end
        #add_reference :cloud_babel_modules, :cloud_babel_accounts, foreign_key: true
    end
end

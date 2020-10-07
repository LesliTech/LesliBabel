class CreateCloudBabelBuckets < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_buckets do |t|
            t.string :name
            t.string :reference_module
            t.datetime :deleted_at
            t.timestamps
        end
        add_reference :cloud_babel_buckets, :cloud_babel_modules, foreign_key: true
    end
end

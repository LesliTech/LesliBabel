class CreateCloudBabelBucketActivities < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_bucket_activities do |t|
            table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000004_activities.json')))
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_babel_bucket_activities, :cloud_babel_buckets, foreign_key: true
    end
end

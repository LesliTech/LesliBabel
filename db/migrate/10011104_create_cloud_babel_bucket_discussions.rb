class CreateCloudBabelBucketDiscussions < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_bucket_discussions do |t|
            table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000005_discussions.json')))
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_babel_bucket_discussions, :users, foreign_key: true
        add_reference :cloud_babel_bucket_discussions, :cloud_babel_bucket_discussions, foreign_key: true, index: { name: "babel_bucket_discussions_discussions" }
        add_reference :cloud_babel_bucket_discussions, :cloud_babel_buckets, foreign_key: true, index: { name: "babel_module_discussions_buckets" }
    end
end

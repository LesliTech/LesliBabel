class CreateCloudBabelTranslationBuckets < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_babel_translation_buckets do |t|
            t.string :name
            t.string :reference_module
            t.timestamps
        end
        #add_reference :cloud_babel_translation_buckets, :cloud_babel_translation_buckets, foreign_key: true, index: { name: "cloud_babel_translation_buckets_buckets" }
        add_reference :cloud_babel_translation_buckets, :cloud_babel_translation_modules, foreign_key: true, index: { name: "babel_translation_objects_modules" }
    end
end

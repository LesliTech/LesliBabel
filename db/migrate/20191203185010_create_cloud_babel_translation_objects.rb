class CreateCloudBabelTranslationObjects < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_babel_translation_objects do |t|

      t.timestamps
    end
  end
end

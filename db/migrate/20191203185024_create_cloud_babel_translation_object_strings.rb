class CreateCloudBabelTranslationObjectStrings < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_babel_translation_object_strings do |t|

      t.timestamps
    end
  end
end

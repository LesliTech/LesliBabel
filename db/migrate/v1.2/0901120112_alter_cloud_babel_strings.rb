class AlterCloudBabelStrings < ActiveRecord::Migration[7.0]
    def change
        add_column :cloud_babel_strings, :sr, :string # Serbian
    end
end

class AlterCloudBabelStrings < ActiveRecord::Migration[6.0]
    def change
        add_column :cloud_babel_strings, :uk, :string #Ukrainian
        add_column :cloud_babel_strings, :ru, :string #Russian
    end
end

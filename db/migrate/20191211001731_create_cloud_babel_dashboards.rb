class CreateCloudBabelDashboards < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_babel_dashboards do |t|

      t.timestamps
    end
  end
end

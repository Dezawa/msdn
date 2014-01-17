class AddColumnToHospitalLimit < ActiveRecord::Migration
  def change
    add_column :hospital_limits,:nurce_id,:integer
  end
end

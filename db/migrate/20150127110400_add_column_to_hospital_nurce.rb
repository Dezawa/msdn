class AddColumnToHospitalNurce < ActiveRecord::Migration
  def change
    add_column :hospital_nurces,:shikaku_id,:integer
  end
end

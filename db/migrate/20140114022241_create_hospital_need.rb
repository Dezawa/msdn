class CreateHospitalNeed < ActiveRecord::Migration
  def change
    create_table :hospital_needs do |t|
      t.integer "daytype"
      t.integer "busho_id"
      t.integer "role_id"
      t.integer "kinmucode_id"
      t.integer "minimun"
      t.integer "maximum"
    end
  end
end

class CreateHospitalNurceHospitalRole < ActiveRecord::Migration
  def change
    create_table :hospital_nurces_roles, id: false do |t|
      t.integer :nurce_id
      t.integer :role_id
    end
  end
end

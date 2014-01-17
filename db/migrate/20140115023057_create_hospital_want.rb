class CreateHospitalWant < ActiveRecord::Migration
  def change
    create_table :hospital_wants do |t|
      t.integer "kinmucode_id"
      t.integer "minimum"
      t.integer "maximum"
    end
  end
end

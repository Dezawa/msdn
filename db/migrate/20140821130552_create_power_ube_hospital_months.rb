class CreatePowerUbeHospitalMonths < ActiveRecord::Migration
  def self.up
    create_table :power_ube_hospital_months do |t|
      t.date    "month"
    end
  end

  def self.down
    drop_table :power_ube_hospital_months
  end
end

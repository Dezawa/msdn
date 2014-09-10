class CreatePowerUbeHospitalPowers < ActiveRecord::Migration
  def self.up
    create_table :power_ube_hospital_powers do |t|
      t.date    "date"
      t.integer "month_id"
      t.integer "weather_id"
      %w(power rev ave by_vaper).each{ |sym|
        ("01".."24").each{ |hr| t.float sym+hr}
      }
    end
  end

  def self.down
    drop_table :power_ube_hospital_powers
  end
end

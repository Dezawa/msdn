class CreateShimadaPowerBy30mins < ActiveRecord::Migration
  Hours = (0..235).step(5).map{ |h| "%03d"%h}
  def change
    create_table :shimada_power_by_30mins do |t|
      t.integer "shimada_factory_id"
      t.date   "date"
      t.integer "month_id"
      t.integer "weather_id"
      Hours.each{ |p| t.float "hour#{p}"}
      Hours.each{ |p| t.float "rev#{p}"}
      Hours.each{ |p| t.float "ave#{p}"}
      Hours.each{ |p| t.float "by_vaper#{p}"}
      t.timestamps
    end
  end
end

class CreateShimadaPowerBy30mins < ActiveRecord::Migration
  Hours = ("00".."24").to_a.map{|h| [h,h+"5"]}.flatten[1,24*2]
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

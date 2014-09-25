class CreateWeatherBy30mins < ActiveRecord::Migration
  Hours = (5..240).step(5).map{ |h| "hour%03d"%h}
  def change
    create_table :weather_by_30mins do |t|
    t.string "location"
    t.date   "month"
    t.date   "date"
      Hours.each{ |p| t.float "hour#{p}"}
      Hours.each{ |p| t.float "vaper#{p}"}
      Hours.each{ |p| t.float "humidit#{p}"}

      t.timestamps
    end
  end
end

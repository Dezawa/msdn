class CreateWeatherLocations < ActiveRecord::Migration
  String_clm= %w(name location forecast_code excite_zip)
  Integer_clm= %w(weather_prec weather_block)
  def self.up
    create_table :weather_locations do |t|
      String_clm.each{ |s| t.string s }
      Integer_clm.each{ |i| t.integer i }
    end
  end

  def self.down
    drop_table :weather_locations
  end
end

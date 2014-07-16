class CreateForecasts < ActiveRecord::Migration
  StrArg   = %w(location)
  DateArg  = %w(date month announce_day)
  TimeArg  = %w(announce)
  Temp     = %w(temp03 temp06 temp09 temp12 temp15 temp18 temp21 temp24) 
  Weather     = %w(weather03 weather06 weather09 weather12 weather15 weather18 weather21 weather24)
  Humi     = %w(humi03 humi06 humi09 humi12 humi15 humi18 humi21 humi24)
  def self.up
    create_table :forecasts do |t|
      StrArg.each{ |clm| t.string clm}
      DateArg.each{ |clm| t.date clm}
      TimeArg.each{ |clm| t.time clm}
      (Temp+Humi).each{ |clm| t.float clm}
      Weather.each{ |clm| t.string clm}   
      t.timestamps
    end
  end

  def self.down
    drop_table :forecasts
  end
end

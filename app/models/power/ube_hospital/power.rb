class Power::UbeHospital::Power < ActiveRecord::Base
  set_table_name 'power_ube_hospital_powers'

  include Power::Power
  belongs_to :month     ,:class_name => "Power::UbeHospital::Month"
  belongs_to :db_weather,:class_name => "Weather" 

  def self.weather_location; "ube" ;end
  def self.weather_location2; "shimonoseki" ;end
  Pram = { 
      2012 => { :threshold => 18.0, :slope_lower => -10.0, :slope_higher => 24.0,
        :y0 => 630.0 , :power_0line => 200.0},
      2013 => { :threshold => 19.0, :slope_lower => -10.0, :slope_higher => 18.0,
        :y0 => 620.0 , :power_0line => 200.0} ,
      2014 => { :threshold => 16.0, :slope_lower => -10.0, :slope_higher => 14.0,
        :y0 => 560.0 , :power_0line => 200.0} ,
    }
  def self.temp_vs_power_param(year)
    param = Pram[year]
    [ :threshold , :slope_lower, :slope_higher, :y0,  :power_0line].map{ |s| param[s]}
  end
  def temp_vs_power_param 
    param = Pram[self.date.year]
    [ :threshold , :slope_lower, :slope_higher, :y0,  :power_0line].map{ |s| param[s]}
  end

  def self.temp_vs_power(opt)
    year = case opt
           when Integer ; opt
           when String  ; opt.to_i
           when Hash
             if opt["year"] ;opt["year"].to_i 
             else ;  return  ""
             end
           else ; return ""
           end
    t,sl,sh,y =  param = temp_vs_power_param(year)
    #t,sl,sh,y = [ :threshold , :slope_lower, :slope_higher, :y0].map{ |s| param[s]}
    
    line = "(x<%f) ?  %+f * (x%+f) %+f : %+f * (x%+f) %+f "%[t,sl,-t,y,sh,-t,y]
    #logger.debug("TEMP_VS_POWER: line = #{line}")
    #line
  end
end

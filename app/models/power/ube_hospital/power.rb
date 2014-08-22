class Power::UbeHospital::Power < ActiveRecord::Base
  set_table_name 'power_ube_hospital_powers'

  include Power::Power
  belongs_to :month     ,:class_name => "Power::UbeHospital::Month"
  belongs_to :db_weather,:class_name => "Weather" 

end

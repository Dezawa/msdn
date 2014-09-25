class Shimada::PowerBy_30min < Shimada::Power
  belongs_to :month     ,:class_name => "Shimada::Month"
  belongs_to :db_weather,:class_name => "WeatherBy30min" 
  belongs_to :shimada_factory     ,:class_name => "Shimada::Factory"
  
end

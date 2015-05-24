class ModifyWeather < ActiveRecord::Migration
  def change
    add_column :weathers,:temp,:string
    add_column :weathers,:vaper,:string
    add_column :weathers,:humi,:string
  end
end

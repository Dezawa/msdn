class AddMonthWeather < ActiveRecord::Migration
  def self.up
    add_column :weathers,:month,:date
  end

  def self.down
    remove_column :weathers,:month
  end
end

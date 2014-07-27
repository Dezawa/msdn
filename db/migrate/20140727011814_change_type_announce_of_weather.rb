class ChangeTypeAnnounceOfWeather < ActiveRecord::Migration
  def self.up
    change_table :forecasts do |t|
      t.change :announce, :datetime
    end
  end

  def self.down
    change_table :forecasts do |t|
      t.change :announce, :time
    end
  end
end

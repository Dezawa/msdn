class AddVaperToForecast < ActiveRecord::Migration
  Vaper    = %w(vaper03 vaper06 vaper09 vaper12 vaper15 vaper18 vaper21 vaper24)
  def self.up
    Vaper.each{ |clm| add_column :forecasts,clm,:float }
  end

  def self.down
    Vaper.each{ |clm| remove_column :forecasts,clm }
  end
end

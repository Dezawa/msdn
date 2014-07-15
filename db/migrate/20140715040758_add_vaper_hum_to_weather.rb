class AddVaperHumToWeather < ActiveRecord::Migration
  def self.up
    ("vaper01".."vaper24").each{ |sym| add_column       :weathers, sym, :float }
    ("humidity01".."humidity24").each{ |sym| add_column :weathers, sym, :float }
  end

  def self.down
    remove_column :weathers,("vaper01".."vaper24").to_a
    remove_column :weathers,("humidity01".."humidity24").to_a
  end
end

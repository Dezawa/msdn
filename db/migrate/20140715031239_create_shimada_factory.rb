class CreateShimadaFactory < ActiveRecord::Migration
  Strings = [:name,:weather_location]
  def self.up
    create_table :shimada_factories do |t|
      Strings.each{ |clm| t.string clm}
    end
  end

  def self.down
    drop_table :shimada_factories
  end
end

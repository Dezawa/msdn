class AddClmnToShimadaPower < ActiveRecord::Migration
  def self.up
    add_column :shimada_powers,:weather_id,:integer
  end

  def self.down
    drop_column :shimada_powers,:weather_id
  end
end

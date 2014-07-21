class AddHukurosuPower < ActiveRecord::Migration
  def self.up
    add_column :shimada_powers,:hukurosu,:float
  end

  def self.down
    remove_column  :shimada_powers,:hukurosu
  end
end

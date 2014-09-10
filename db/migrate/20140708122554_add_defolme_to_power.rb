class AddDefolmeToPower < ActiveRecord::Migration
  def self.up
    add_column :shimada_powers,:deform,:string
  end

  def self.down
    remove_column :shimada_powers,:deform
  end
end

class AddShapeToPower < ActiveRecord::Migration
  def self.up
      add_column :shimada_powers,:shape,:string
  end

  def self.down
      drop_column :shimada_powers,:shape
  end
end

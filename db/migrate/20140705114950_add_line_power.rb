class AddLinePower < ActiveRecord::Migration
  def self.up
    add_column :shimada_powers, :line ,:integer
  end

  def self.down
    remove_column  :shimada_powers, :line
  end
end

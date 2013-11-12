class AddRoundsizeProducts < ActiveRecord::Migration
  def self.up
    add_column :ube_products,:roundsize,:integer;
  end

  def self.down
    drop_column :ube_products,:roundsize
  end
end

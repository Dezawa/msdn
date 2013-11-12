class AddAddminToConstant < ActiveRecord::Migration
  def self.up
    add_column :ube_constants,:admin,:bool
  end

  def self.down
    drop_column :ube_constants,:admin
  end
end

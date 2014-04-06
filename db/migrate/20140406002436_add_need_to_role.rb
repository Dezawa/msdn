class AddNeedToRole < ActiveRecord::Migration
  def self.up
    add_column :hospital_roles,:need,:bool
  end

  def self.down
    remove_column :hospital_roles,:need
  end
end

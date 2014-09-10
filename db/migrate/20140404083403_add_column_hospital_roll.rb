class AddColumnHospitalRoll < ActiveRecord::Migration
  def self.up
    add_column :hospital_roles,:bunrui,:integer
  end

  def self.down
    remove_column :hospital_roles,:bunrui
  end
end

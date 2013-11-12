class AddcolumnCode < ActiveRecord::Migration
  def self.up
    rename_column :hospital_kinmucodes,:daytime,:am
    rename_column :hospital_kinmucodes,:daytime2,:am2
    add_column :hospital_kinmucodes,:pm,:float
    add_column :hospital_kinmucodes,:pm2,:float

  end

  def self.down
  end
end

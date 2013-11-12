class RenameDefine < ActiveRecord::Migration
  def self.up
    rename_column :hospital_defines,:attribute,:attri
  end

  def self.down
    rename_column :hospital_defines,:attri,:attribute
  end
end

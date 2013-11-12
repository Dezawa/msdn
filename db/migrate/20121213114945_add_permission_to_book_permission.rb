class AddPermissionToBookPermission < ActiveRecord::Migration
  def self.up
    add_column :book_permissions, :permission , :integer
  end

  def self.down
    drop_culmn :book_permissions, :permission
  end
end

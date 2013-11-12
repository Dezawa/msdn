class RenameBookUsersToBookPermission < ActiveRecord::Migration
  def self.up
    rename_table :book_users,:book_permissions
  end

  def self.down
    rename_table :book_permissions,:book_users
  end
end

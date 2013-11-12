class AddUserIdToBookPermission < ActiveRecord::Migration
  def self.up
    add_column :book_permissions,:user_id,:integer
  end

  def self.down
    drop_column :book_permissions,:user_id
  end
end

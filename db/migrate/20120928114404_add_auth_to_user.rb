class AddAuthToUser < ActiveRecord::Migration
  def self.up
     add_column :user_options,:authorized,:text
  end

  def self.down
     drop_column :user_options,:authorized
  end
end

class RenameTableUserOptionUser < ActiveRecord::Migration
  def change
    rename_table :user_option_users, :user_options_users
  end
end

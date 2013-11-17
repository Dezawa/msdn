class CreateUserOptionUser < ActiveRecord::Migration
  def change
    create_table :user_option_users, :id => false do |t|
      t.integer "user_id"
      t.integer "user_option_id"
    end
  end
end

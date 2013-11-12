class CreateBookUsers < ActiveRecord::Migration
  def self.up
    create_table :book_users do |t|
      t.string :login
      t.string :owner
      t.boolean   :show
      t.boolean   :edit
      t.timestamps
    end
  end

  def self.down
    drop_table :book_users
  end
end

class BookMainAddOwner < ActiveRecord::Migration
  def self.up
    add_column :book_mains, :owner,:text 
  end

  def self.down
    drop_colmn  :book_mains, :owner
  end
end

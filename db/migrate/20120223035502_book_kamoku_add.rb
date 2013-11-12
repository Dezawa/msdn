class BookKamokuAdd < ActiveRecord::Migration
  def self.up
    add_column :book_kamokus, :code,:integer 
  end

  def self.down
    drop_colmn :book_kamokus, :code
  end
end

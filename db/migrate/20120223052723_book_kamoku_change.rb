class BookKamokuChange < ActiveRecord::Migration
  def self.up
    change_column :book_kamokus,:bunrui,:integer
  end

  def self.down
  end
end

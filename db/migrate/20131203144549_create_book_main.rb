class CreateBookMain < ActiveRecord::Migration
  def change
    create_table :book_mains do |t|
    t.integer "no"
    t.date    "date"
    t.integer "kasikata"
    t.integer "karikata"
    t.text    "tytle"
    t.text    "memo"
    t.integer "amount"
    t.text    "owner"
    end
  end
end

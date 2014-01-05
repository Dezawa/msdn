class CreateBookKamoku < ActiveRecord::Migration
  def change
    create_table :book_kamokus do |t|
    t.text    "kamoku"
    t.integer "bunrui"
    t.integer "code"
    end
  end
end

class CreateHolyday < ActiveRecord::Migration
  def change
    create_table :holydays do |t|
      t.integer "year"
      t.date    "day"
      t.string  "name"
    end
  end
end

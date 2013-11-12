class CreateHolydays < ActiveRecord::Migration
  def self.up
    create_table "holydays", :force => true do |t|
      t.integer "year"
      t.date    "day"
      t.string  "name"
    end
  end

  def self.down
  end
end

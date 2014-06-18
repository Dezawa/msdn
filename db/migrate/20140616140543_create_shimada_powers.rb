class CreateShimadaPowers < ActiveRecord::Migration
  def self.up
    create_table :shimada_powers do |t|
      t.date :date
      t.integer :month_id
      ("hour01".."hour24").each{ |sym| t.float sym}
    end
  end

  def self.down
    drop_table :shimada_powers
  end
end

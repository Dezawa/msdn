class AddCachColumnToPower < ActiveRecord::Migration
  Differ = ("00".."23").map{ |h| "difference#{h}" }
  NA     = ("f4_na0".."f4_na4").to_a
  F3_SOLVE = %w(f3_x1 f3_x2 f3_x3)
  F2_SOLVE = %w(f2_x1 f2_x2)
  AddColumns = Differ + NA + F3_SOLVE + F2_SOLVE
  RmColumns = AddColumns
  def self.up
    AddColumns.each{ |clm| add_column :shimada_powers, clm, :float }
  end

  def self.down
    RmColumns.each{ |clm| remove_column :shimada_powers, clm }
  end
end

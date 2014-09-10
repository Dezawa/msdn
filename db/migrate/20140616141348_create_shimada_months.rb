class CreateShimadaMonths < ActiveRecord::Migration
  def self.up
    create_table :shimada_months do |t|  
      t.date :month
    end
  end

  def self.down
    drop_table :shimada_months
  end
end

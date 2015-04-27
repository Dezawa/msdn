class AddClm2dayly < ActiveRecord::Migration
  def change
    add_column :shimada_daylies,:interval,:integer
  end
end

class CreateShimadaDaylies < ActiveRecord::Migration
  def change
    create_table :shimada_daylies do |t|

      t.timestamps null: false
    end
  end
end

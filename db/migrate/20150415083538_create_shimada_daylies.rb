class CreateShimadaDaylies < ActiveRecord::Migration
  def change
    create_table :shimada_daylies do |t|
      t.date     "month"
      t.date     "date"
      t.string   "base_name"
      t.string   "ch_name"
      t.string   "measurement_type"
      t.text     "measurement_value"
      t.text     "converted_value"
      t.integer  :shimada_instruments_id
      t.timestamps null: false
    end
  end
end

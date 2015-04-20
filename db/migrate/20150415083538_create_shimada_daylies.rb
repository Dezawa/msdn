class CreateShimadaDaylies < ActiveRecord::Migration
  def change
    create_table :shimada_daylies do |t|
      t.date     "month"
      t.date     "date"
      t.string   "serial"
      t.string   "ch_name_type"
      t.string   "measurement_type"
      t.text     "measurement_value"
      t.text     "converted_value"
      t.integer  :instrument_id
      t.timestamps null: false
    end
  end
end

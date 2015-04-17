class CreateShimadaInstruments < ActiveRecord::Migration
  def change
    create_table :shimada_instruments do |t|
      t.string   :serial
      t.string   "base_name"
      t.string   "ch_name"
      t.string   "measurement_type"
      t.string   :unit
      t.string   :comment
      t.integer   :converter ,default: 0
      t.float    :slope ,default: 1.0
      t.float    :graft ,default: 0.0

      t.timestamps null: false
    end
  end
end

class CreateSolaInstruments < ActiveRecord::Migration
  def change
    create_table :sola_instruments do |t|
    t.string   "serial",           limit: 255
    t.string   "base_name",        limit: 255
    t.string   "ch_name",          limit: 255
    t.string   "measurement_type", limit: 255
    t.string   "measurement",      limit: 255
    t.string   "unit",             limit: 255
    t.string   "comment",          limit: 255
    t.integer  "converter",        limit: 4,   default: 0
    t.float    "slope",            limit: 24,  default: 1.0
    t.float    "graft",            limit: 24,  default: 0.0

      t.timestamps null: false
    end
  end
end

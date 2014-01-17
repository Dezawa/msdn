class CreateHospitalMeeting < ActiveRecord::Migration
  def change
    create_table :hospital_meetings do |t|
      t.integer  "busho_id"
      t.date     "month"
      t.integer  "number"
      t.string   "name"
      t.datetime "start"
      t.float    "length"
      t.boolean  "kaigi",    :default => true
    end
  end
end

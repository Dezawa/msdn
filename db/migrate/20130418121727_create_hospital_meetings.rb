class CreateHospitalMeetings < ActiveRecord::Migration
  def self.up
    create_table "hospital_meetings", :force => true do |t|
      t.integer  "busho_id"
      t.date     "month"
      t.integer  "number"
      t.string   "name"
      t.datetime "start"
      t.float    "length"
      t.boolean  "kaigi",    :default => true
    end
  end

  def self.down
  end
end

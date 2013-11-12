class CreateHospitalKinmucodes < ActiveRecord::Migration
  def self.up

    create_table "hospital_kinmucodes", :force => true do |t|
      t.string  "code"
      t.integer "kinmukubun_id"
      t.integer "with_mousiokuri"
      t.float   "main_daytime"
      t.float   "main_nignt"
      t.float   "sub_daytime"
      t.float   "sub_night"
      t.string  "name"
      t.string  "color"
      t.string  "start"
      t.string  "finish"
      t.float   "main_next"
      t.float   "sub_next"
      t.float   "daytime"
      t.float   "night"
      t.float   "midnight"
      t.float   "daytime2"
      t.float   "night2"
      t.float   "midnight2"
      t.float   "nenkyuu"
    end
  end

  def self.down
  end
end

class CreateHospitalKinmucode < ActiveRecord::Migration
  def change
    create_table :hospital_kinmucodes do |t|
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
    t.float   "am",              :default => 0.0
    t.float   "night",           :default => 0.0
    t.float   "midnight",        :default => 0.0
    t.float   "am2",             :default => 0.0
    t.float   "night2",          :default => 0.0
    t.float   "midnight2",       :default => 0.0
    t.float   "nenkyuu"
    t.float   "pm",              :default => 0.0
    t.float   "pm2",             :default => 0.0
    end
  end
end

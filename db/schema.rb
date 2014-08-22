# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140821131110) do

  create_table "book_kamokus", :force => true do |t|
    t.text    "kamoku"
    t.integer "bunrui"
    t.integer "code"
  end

  create_table "book_mains", :force => true do |t|
    t.integer "no"
    t.date    "date"
    t.integer "kasikata"
    t.integer "karikata"
    t.text    "tytle"
    t.text    "memo"
    t.integer "amount"
    t.text    "owner"
  end

  create_table "book_permissions", :force => true do |t|
    t.string   "login"
    t.string   "owner"
    t.boolean  "show"
    t.boolean  "edit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "permission"
    t.integer  "user_id"
  end

  create_table "bushos", :force => true do |t|
    t.string "name"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "forecasts", :force => true do |t|
    t.string   "location"
    t.date     "date"
    t.date     "month"
    t.date     "announce_day"
    t.datetime "announce"
    t.float    "temp03"
    t.float    "temp06"
    t.float    "temp09"
    t.float    "temp12"
    t.float    "temp15"
    t.float    "temp18"
    t.float    "temp21"
    t.float    "temp24"
    t.float    "humi03"
    t.float    "humi06"
    t.float    "humi09"
    t.float    "humi12"
    t.float    "humi15"
    t.float    "humi18"
    t.float    "humi21"
    t.float    "humi24"
    t.string   "weather03"
    t.string   "weather06"
    t.string   "weather09"
    t.string   "weather12"
    t.string   "weather15"
    t.string   "weather18"
    t.string   "weather21"
    t.string   "weather24"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "vaper03"
    t.float    "vaper06"
    t.float    "vaper09"
    t.float    "vaper12"
    t.float    "vaper15"
    t.float    "vaper18"
    t.float    "vaper21"
    t.float    "vaper24"
  end

  create_table "holydays", :force => true do |t|
    t.integer "year"
    t.date    "day"
    t.string  "name"
  end

  create_table "hospital_avoid_combinations", :force => true do |t|
    t.integer "busho_id"
    t.integer "nurce1_id"
    t.integer "nurce2_id"
    t.integer "weight"
  end

  create_table "hospital_defines", :force => true do |t|
    t.string "name"
    t.string "attri"
    t.string "value"
    t.string "comment"
  end

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

  create_table "hospital_limits", :force => true do |t|
    t.integer "code0"
    t.integer "code1"
    t.integer "code2"
    t.integer "code3"
    t.integer "coden"
    t.integer "busho_id"
    t.integer "kinmu_total"
    t.integer "night_total"
  end

  create_table "hospital_meetings", :force => true do |t|
    t.integer  "busho_id"
    t.date     "month"
    t.integer  "number"
    t.string   "name"
    t.datetime "start"
    t.float    "length"
    t.boolean  "kaigi",    :default => true
  end

  create_table "hospital_monthlies", :force => true do |t|
    t.date    "month"
    t.integer "day00"
    t.integer "day01"
    t.integer "day02"
    t.integer "day03"
    t.integer "day04"
    t.integer "day05"
    t.integer "day06"
    t.integer "day07"
    t.integer "day08"
    t.integer "day09"
    t.integer "day10"
    t.integer "day11"
    t.integer "day12"
    t.integer "day13"
    t.integer "day14"
    t.integer "day15"
    t.integer "day16"
    t.integer "day17"
    t.integer "day18"
    t.integer "day19"
    t.integer "day20"
    t.integer "day21"
    t.integer "day22"
    t.integer "day23"
    t.integer "day24"
    t.integer "day25"
    t.integer "day26"
    t.integer "day27"
    t.integer "day28"
    t.integer "day29"
    t.integer "day30"
    t.integer "day31"
    t.integer "nurce_id"
  end

  create_table "hospital_needs", :force => true do |t|
    t.integer "daytype"
    t.integer "busho_id"
    t.integer "role_id"
    t.integer "kinmucode_id"
    t.integer "minimun"
    t.integer "maximum"
  end

  create_table "hospital_roles", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "comment"
    t.integer  "bunrui"
    t.boolean  "need"
  end

  create_table "hospital_wants", :force => true do |t|
    t.integer "kinmucode_id"
    t.integer "minimum"
    t.integer "maximum"
  end

  create_table "labels", :force => true do |t|
    t.string "system"
    t.string "labelid"
    t.string "label"
    t.text   "labeloption"
  end

  create_table "nurces", :force => true do |t|
    t.string  "name"
    t.integer "number"
    t.integer "busho_id"
    t.integer "pre_busho_id"
    t.integer "pre_shokui_id"
    t.integer "pre_shokushu_id"
    t.integer "pre_kinmukubun_id"
    t.date    "assign_date"
    t.integer "idou"
    t.integer "limit_id"
  end

  create_table "nurces_roles", :id => false, :force => true do |t|
    t.integer "nurce_id"
    t.integer "role_id"
  end

  create_table "power_ube_hospital_months", :force => true do |t|
    t.date "month"
  end

  create_table "power_ube_hospital_powers", :force => true do |t|
    t.date    "date"
    t.integer "month_id"
    t.integer "weather_id"
    t.float   "power01"
    t.float   "power02"
    t.float   "power03"
    t.float   "power04"
    t.float   "power05"
    t.float   "power06"
    t.float   "power07"
    t.float   "power08"
    t.float   "power09"
    t.float   "power10"
    t.float   "power11"
    t.float   "power12"
    t.float   "power13"
    t.float   "power14"
    t.float   "power15"
    t.float   "power16"
    t.float   "power17"
    t.float   "power18"
    t.float   "power19"
    t.float   "power20"
    t.float   "power21"
    t.float   "power22"
    t.float   "power23"
    t.float   "power24"
    t.float   "rev01"
    t.float   "rev02"
    t.float   "rev03"
    t.float   "rev04"
    t.float   "rev05"
    t.float   "rev06"
    t.float   "rev07"
    t.float   "rev08"
    t.float   "rev09"
    t.float   "rev10"
    t.float   "rev11"
    t.float   "rev12"
    t.float   "rev13"
    t.float   "rev14"
    t.float   "rev15"
    t.float   "rev16"
    t.float   "rev17"
    t.float   "rev18"
    t.float   "rev19"
    t.float   "rev20"
    t.float   "rev21"
    t.float   "rev22"
    t.float   "rev23"
    t.float   "rev24"
    t.float   "ave01"
    t.float   "ave02"
    t.float   "ave03"
    t.float   "ave04"
    t.float   "ave05"
    t.float   "ave06"
    t.float   "ave07"
    t.float   "ave08"
    t.float   "ave09"
    t.float   "ave10"
    t.float   "ave11"
    t.float   "ave12"
    t.float   "ave13"
    t.float   "ave14"
    t.float   "ave15"
    t.float   "ave16"
    t.float   "ave17"
    t.float   "ave18"
    t.float   "ave19"
    t.float   "ave20"
    t.float   "ave21"
    t.float   "ave22"
    t.float   "ave23"
    t.float   "ave24"
    t.float   "by_vaper01"
    t.float   "by_vaper02"
    t.float   "by_vaper03"
    t.float   "by_vaper04"
    t.float   "by_vaper05"
    t.float   "by_vaper06"
    t.float   "by_vaper07"
    t.float   "by_vaper08"
    t.float   "by_vaper09"
    t.float   "by_vaper10"
    t.float   "by_vaper11"
    t.float   "by_vaper12"
    t.float   "by_vaper13"
    t.float   "by_vaper14"
    t.float   "by_vaper15"
    t.float   "by_vaper16"
    t.float   "by_vaper17"
    t.float   "by_vaper18"
    t.float   "by_vaper19"
    t.float   "by_vaper20"
    t.float   "by_vaper21"
    t.float   "by_vaper22"
    t.float   "by_vaper23"
    t.float   "by_vaper24"
  end

  create_table "shimada_factories", :force => true do |t|
    t.string "name"
    t.string "weather_location"
    t.string "forecast_location"
  end

  create_table "shimada_months", :force => true do |t|
    t.date    "month"
    t.integer "shimada_factory_id"
  end

  create_table "shimada_powers", :force => true do |t|
    t.date    "date"
    t.integer "month_id"
    t.float   "hour01"
    t.float   "hour02"
    t.float   "hour03"
    t.float   "hour04"
    t.float   "hour05"
    t.float   "hour06"
    t.float   "hour07"
    t.float   "hour08"
    t.float   "hour09"
    t.float   "hour10"
    t.float   "hour11"
    t.float   "hour12"
    t.float   "hour13"
    t.float   "hour14"
    t.float   "hour15"
    t.float   "hour16"
    t.float   "hour17"
    t.float   "hour18"
    t.float   "hour19"
    t.float   "hour20"
    t.float   "hour21"
    t.float   "hour22"
    t.float   "hour23"
    t.float   "hour24"
    t.integer "weather_id"
    t.float   "rev01"
    t.float   "rev02"
    t.float   "rev03"
    t.float   "rev04"
    t.float   "rev05"
    t.float   "rev06"
    t.float   "rev07"
    t.float   "rev08"
    t.float   "rev09"
    t.float   "rev10"
    t.float   "rev11"
    t.float   "rev12"
    t.float   "rev13"
    t.float   "rev14"
    t.float   "rev15"
    t.float   "rev16"
    t.float   "rev17"
    t.float   "rev18"
    t.float   "rev19"
    t.float   "rev20"
    t.float   "rev21"
    t.float   "rev22"
    t.float   "rev23"
    t.float   "rev24"
    t.float   "ave01"
    t.float   "ave02"
    t.float   "ave03"
    t.float   "ave04"
    t.float   "ave05"
    t.float   "ave06"
    t.float   "ave07"
    t.float   "ave08"
    t.float   "ave09"
    t.float   "ave10"
    t.float   "ave11"
    t.float   "ave12"
    t.float   "ave13"
    t.float   "ave14"
    t.float   "ave15"
    t.float   "ave16"
    t.float   "ave17"
    t.float   "ave18"
    t.float   "ave19"
    t.float   "ave20"
    t.float   "ave21"
    t.float   "ave22"
    t.float   "ave23"
    t.float   "ave24"
    t.string  "shape"
    t.float   "difference00"
    t.float   "difference01"
    t.float   "difference02"
    t.float   "difference03"
    t.float   "difference04"
    t.float   "difference05"
    t.float   "difference06"
    t.float   "difference07"
    t.float   "difference08"
    t.float   "difference09"
    t.float   "difference10"
    t.float   "difference11"
    t.float   "difference12"
    t.float   "difference13"
    t.float   "difference14"
    t.float   "difference15"
    t.float   "difference16"
    t.float   "difference17"
    t.float   "difference18"
    t.float   "difference19"
    t.float   "difference20"
    t.float   "difference21"
    t.float   "difference22"
    t.float   "difference23"
    t.float   "f4_na0"
    t.float   "f4_na1"
    t.float   "f4_na2"
    t.float   "f4_na3"
    t.float   "f4_na4"
    t.float   "f3_x1"
    t.float   "f3_x2"
    t.float   "f3_x3"
    t.float   "f2_x1"
    t.float   "f2_x2"
    t.integer "line"
    t.string  "deform"
    t.float   "hukurosu"
    t.float   "by_vaper01"
    t.float   "by_vaper02"
    t.float   "by_vaper03"
    t.float   "by_vaper04"
    t.float   "by_vaper05"
    t.float   "by_vaper06"
    t.float   "by_vaper07"
    t.float   "by_vaper08"
    t.float   "by_vaper09"
    t.float   "by_vaper10"
    t.float   "by_vaper11"
    t.float   "by_vaper12"
    t.float   "by_vaper13"
    t.float   "by_vaper14"
    t.float   "by_vaper15"
    t.float   "by_vaper16"
    t.float   "by_vaper17"
    t.float   "by_vaper18"
    t.float   "by_vaper19"
    t.float   "by_vaper20"
    t.float   "by_vaper21"
    t.float   "by_vaper22"
    t.float   "by_vaper23"
    t.float   "by_vaper24"
    t.integer "shimada_factory_id"
  end

  create_table "top_pages", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ube_change_times", :force => true do |t|
    t.text    "ope_name"
    t.text    "ope_type"
    t.integer "change_time"
    t.text    "ope_from"
    t.text    "ope_to"
  end

  create_table "ube_constants", :force => true do |t|
    t.text    "name"
    t.integer "value"
    t.text    "comment"
    t.boolean "admin"
    t.text    "keyword"
  end

  create_table "ube_holydays", :force => true do |t|
    t.text "month"
    t.text "shozow"
    t.text "shozoe"
    t.text "dryo"
    t.text "dryn"
    t.text "kakou"
  end

  create_table "ube_maintains", :force => true do |t|
    t.string   "ope_name"
    t.datetime "plan_time_start"
    t.datetime "plan_time_end"
    t.string   "memo"
    t.text     "maintain_no"
    t.text     "maintain"
  end

  create_table "ube_meigara_shortnames", :force => true do |t|
    t.text    "name"
    t.text    "short_name"
    t.integer "ube_meigara_id"
  end

  create_table "ube_meigaras", :force => true do |t|
    t.text "meigara"
    t.text "proname"
  end

  create_table "ube_named_changes", :force => true do |t|
    t.integer "jun"
    t.integer "pre_condition_id"
    t.integer "post_condition_id"
    t.text    "ope_name"
    t.text    "display"
  end

  create_table "ube_operations", :force => true do |t|
    t.text  "ope_name"
    t.float "west"
    t.float "east"
    t.float "old"
    t.float "new"
    t.float "kakou"
  end

  create_table "ube_plans", :force => true do |t|
    t.integer  "jun"
    t.string   "lot_no"
    t.integer  "mass"
    t.integer  "ube_product_id"
    t.text     "meigara"
    t.integer  "yojoko"
    t.datetime "plan_shozo_from"
    t.datetime "plan_shozo_to"
    t.datetime "plan_yojo_from"
    t.datetime "plan_yojo_to"
    t.datetime "plan_dry_from"
    t.datetime "plan_dry_to"
    t.datetime "plan_kakou_from"
    t.datetime "plan_kakou_to"
    t.datetime "result_shozo_from"
    t.datetime "result_shozo_to"
    t.datetime "result_yojo_from"
    t.datetime "result_yojo_to"
    t.datetime "result_dry_from"
    t.datetime "result_dry_to"
    t.datetime "result_kakou_from"
    t.datetime "result_kakou_to"
    t.datetime "plan_dry_out"
    t.datetime "plan_dry_end"
  end

  create_table "ube_plans_ube_skds", :id => false, :force => true do |t|
    t.integer "ube_plan_id"
    t.integer "ube_skd_id"
  end

  create_table "ube_products", :force => true do |t|
    t.string  "proname"
    t.string  "shozo"
    t.string  "dryer"
    t.integer "lot_size"
    t.float   "defect_rate"
    t.text    "ope_condition"
    t.text    "color"
    t.boolean "hozen"
    t.integer "roundsize"
  end

  create_table "ube_skds", :force => true do |t|
    t.text     "title"
    t.datetime "skd_from"
    t.datetime "skd_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "runtime_shozo_w"
    t.integer  "runtime_shozo_e"
    t.integer  "runtime_dry_o"
    t.integer  "runtime_dry_n"
    t.integer  "runtime_kakou"
    t.integer  "donetime_shozo_w"
    t.integer  "donetime_shozo_e"
    t.integer  "donetime_dry_o"
    t.integer  "donetime_dry_n"
    t.integer  "donetime_kakou"
    t.integer  "plantime_shozo_w"
    t.integer  "plantime_shozo_e"
    t.integer  "plantime_dry_o"
    t.integer  "plantime_dry_n"
    t.integer  "plantime_kakou"
    t.integer  "month"
    t.integer  "freetime_shozo_w"
    t.integer  "freetime_shozo_e"
    t.integer  "freetime_dry_o"
    t.integer  "freetime_dry_n"
    t.integer  "freetime_kakou"
    t.integer  "mainttime_shozo_w"
    t.integer  "changetime_shozo_w"
    t.integer  "mainttime_shozo_e"
    t.integer  "changetime_shozo_e"
    t.integer  "mainttime_dry_o"
    t.integer  "changetime_dry_o"
    t.integer  "mainttime_dry_n"
    t.integer  "changetime_dry_n"
    t.integer  "mainttime_kakou"
    t.integer  "changetime_kakou"
    t.integer  "running_wf_shozow"
    t.integer  "running_wf_shozoe"
    t.integer  "running_pf_shozow"
    t.integer  "running_pf_shozoe"
    t.integer  "running_dryo"
    t.integer  "running_dryn"
    t.integer  "runned_wf_shozow"
    t.integer  "runned_wf_shozoe"
    t.integer  "runned_pf_shozow"
    t.integer  "runned_pf_shozoe"
    t.integer  "runned_dryo"
    t.integer  "runned_dryn"
    t.text     "message"
    t.text     "free_list"
    t.integer  "limit_wf_shozow"
    t.integer  "limit_wf_shozoe"
    t.integer  "limit_pf_shozow"
    t.integer  "limit_pf_shozoe"
    t.integer  "limit_dryero"
    t.integer  "limit_dryern"
    t.boolean  "jun_only"
    t.date     "plan_from"
  end

  create_table "ubr_pillars", :force => true do |t|
    t.string  "name"
    t.integer "souko_floor_id"
    t.integer "kazu_x"
    t.integer "kazu_y"
    t.float   "start_x"
    t.float   "start_y"
    t.float   "kankaku_x"
    t.float   "kankaku_y"
    t.float   "size_x"
    t.float   "size_y"
  end

  create_table "ubr_souko_floor_souko_plans", :force => true do |t|
    t.integer "souko_floor_id"
    t.integer "souko_plan_id"
    t.float   "floor_offset_x"
    t.float   "floor_offset_y"
  end

  create_table "ubr_souko_floor_waku_blocks", :id => false, :force => true do |t|
    t.integer "souko_floor_id"
    t.integer "waku_block_id"
  end

  create_table "ubr_souko_floors", :force => true do |t|
    t.text  "name"
    t.float "outline_x0"
    t.float "outline_y0"
    t.float "outline_x1"
    t.float "outline_y1"
  end

  create_table "ubr_souko_plans", :force => true do |t|
    t.text    "name"
    t.text    "stat_name_list"
    t.text    "stat_reg_list"
    t.float   "offset_x"
    t.float   "offset_y"
    t.float   "stat_offset_x"
    t.float   "stat_offset_y"
    t.float   "stat_font"
    t.float   "stat_point"
    t.boolean "landscape"
  end

  create_table "ubr_waku_blocks", :force => true do |t|
    t.integer "souko_floor_id"
    t.text    "souko"
    t.text    "content"
    t.text    "sufix"
    t.text    "max"
    t.float   "label_pos_x"
    t.float   "label_pos_y"
    t.float   "base_point_x"
    t.float   "base_point_y"
  end

  create_table "ubr_wakus", :force => true do |t|
    t.text    "name"
    t.text    "areaknb"
    t.text    "direct_to"
    t.text    "palette"
    t.integer "volum"
    t.integer "dan3"
    t.integer "dan2"
    t.integer "dan1"
    t.integer "retusu"
    t.float   "pos_x"
    t.float   "pos_y"
  end

  create_table "ubr_walls", :force => true do |t|
    t.integer "souko_floor_id"
    t.float   "name"
    t.float   "x0"
    t.float   "y0"
    t.float   "dx1"
    t.float   "dy1"
    t.float   "dx2"
    t.float   "dy2"
    t.float   "dx3"
    t.float   "dy3"
    t.float   "dx4"
    t.float   "dy4"
  end

  create_table "user_options", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "label"
    t.text     "url"
    t.integer  "order"
    t.text     "comment"
    t.text     "authorized"
  end

  create_table "user_options_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "user_option_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.boolean  "lipscsvio",                                :default => false
    t.boolean  "lipssizeoption",                           :default => false
    t.integer  "lipssizepro",                              :default => 10
    t.integer  "lipssizeope",                              :default => 10
    t.string   "lipslabelcode",                            :default => "default"
    t.string   "lipsoptlink"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "weather_locations", :force => true do |t|
    t.string  "name"
    t.string  "location"
    t.string  "weather_block"
    t.string  "forecast_code"
    t.string  "excite_zip"
    t.integer "weather_prec"
  end

  create_table "weathers", :force => true do |t|
    t.string "location"
    t.date   "date"
    t.float  "hour01"
    t.float  "hour02"
    t.float  "hour03"
    t.float  "hour04"
    t.float  "hour05"
    t.float  "hour06"
    t.float  "hour07"
    t.float  "hour08"
    t.float  "hour09"
    t.float  "hour10"
    t.float  "hour11"
    t.float  "hour12"
    t.float  "hour13"
    t.float  "hour14"
    t.float  "hour15"
    t.float  "hour16"
    t.float  "hour17"
    t.float  "hour18"
    t.float  "hour19"
    t.float  "hour20"
    t.float  "hour21"
    t.float  "hour22"
    t.float  "hour23"
    t.float  "hour24"
    t.date   "month"
    t.float  "vaper01"
    t.float  "vaper02"
    t.float  "vaper03"
    t.float  "vaper04"
    t.float  "vaper05"
    t.float  "vaper06"
    t.float  "vaper07"
    t.float  "vaper08"
    t.float  "vaper09"
    t.float  "vaper10"
    t.float  "vaper11"
    t.float  "vaper12"
    t.float  "vaper13"
    t.float  "vaper14"
    t.float  "vaper15"
    t.float  "vaper16"
    t.float  "vaper17"
    t.float  "vaper18"
    t.float  "vaper19"
    t.float  "vaper20"
    t.float  "vaper21"
    t.float  "vaper22"
    t.float  "vaper23"
    t.float  "vaper24"
    t.float  "humidity01"
    t.float  "humidity02"
    t.float  "humidity03"
    t.float  "humidity04"
    t.float  "humidity05"
    t.float  "humidity06"
    t.float  "humidity07"
    t.float  "humidity08"
    t.float  "humidity09"
    t.float  "humidity10"
    t.float  "humidity11"
    t.float  "humidity12"
    t.float  "humidity13"
    t.float  "humidity14"
    t.float  "humidity15"
    t.float  "humidity16"
    t.float  "humidity17"
    t.float  "humidity18"
    t.float  "humidity19"
    t.float  "humidity20"
    t.float  "humidity21"
    t.float  "humidity22"
    t.float  "humidity23"
    t.float  "humidity24"
  end

end

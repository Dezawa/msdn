# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 201409131724152) do

  create_table "book_kamokus", force: true do |t|
    t.text    "kamoku"
    t.integer "bunrui"
    t.integer "code"
  end

  create_table "book_mains", force: true do |t|
    t.integer "no"
    t.date    "date"
    t.integer "kasikata"
    t.integer "karikata"
    t.text    "tytle"
    t.text    "memo"
    t.integer "amount"
    t.text    "owner"
  end

  create_table "book_permissions", force: true do |t|
    t.string   "login"
    t.string   "owner"
    t.boolean  "show"
    t.boolean  "edit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "permission"
    t.integer  "user_id"
  end

  create_table "bushos", force: true do |t|
    t.string "name"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "forecasts", force: true do |t|
    t.string   "location"
    t.date     "date"
    t.date     "month"
    t.date     "announce_day"
    t.datetime "announce"
    t.float    "temp03",       limit: 24
    t.float    "temp06",       limit: 24
    t.float    "temp09",       limit: 24
    t.float    "temp12",       limit: 24
    t.float    "temp15",       limit: 24
    t.float    "temp18",       limit: 24
    t.float    "temp21",       limit: 24
    t.float    "temp24",       limit: 24
    t.float    "humi03",       limit: 24
    t.float    "humi06",       limit: 24
    t.float    "humi09",       limit: 24
    t.float    "humi12",       limit: 24
    t.float    "humi15",       limit: 24
    t.float    "humi18",       limit: 24
    t.float    "humi21",       limit: 24
    t.float    "humi24",       limit: 24
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
    t.float    "vaper03",      limit: 24
    t.float    "vaper06",      limit: 24
    t.float    "vaper09",      limit: 24
    t.float    "vaper12",      limit: 24
    t.float    "vaper15",      limit: 24
    t.float    "vaper18",      limit: 24
    t.float    "vaper21",      limit: 24
    t.float    "vaper24",      limit: 24
  end

  create_table "holydays", force: true do |t|
    t.integer "year"
    t.date    "day"
    t.string  "name"
  end

  create_table "hospital_avoid_combinations", force: true do |t|
    t.integer "busho_id"
    t.integer "nurce1_id"
    t.integer "nurce2_id"
    t.integer "weight"
  end

  create_table "hospital_bushos", force: true do |t|
    t.string "name"
  end

  create_table "hospital_defines", force: true do |t|
    t.string "name"
    t.string "attri"
    t.string "value"
    t.string "comment"
  end

  create_table "hospital_kinmucodes", force: true do |t|
    t.string  "code"
    t.integer "kinmukubun_id"
    t.integer "with_mousiokuri"
    t.float   "main_daytime",    limit: 24
    t.float   "main_nignt",      limit: 24
    t.float   "sub_daytime",     limit: 24
    t.float   "sub_night",       limit: 24
    t.string  "name"
    t.string  "color"
    t.string  "start"
    t.string  "finish"
    t.float   "main_next",       limit: 24
    t.float   "sub_next",        limit: 24
    t.float   "am",              limit: 24, default: 0.0
    t.float   "night",           limit: 24, default: 0.0
    t.float   "midnight",        limit: 24, default: 0.0
    t.float   "am2",             limit: 24, default: 0.0
    t.float   "night2",          limit: 24, default: 0.0
    t.float   "midnight2",       limit: 24, default: 0.0
    t.float   "nenkyuu",         limit: 24, default: 0.0
    t.float   "pm",              limit: 24, default: 0.0
    t.float   "pm2",             limit: 24, default: 0.0
  end

  create_table "hospital_limits", force: true do |t|
    t.integer "code0"
    t.integer "code1"
    t.integer "code2"
    t.integer "code3"
    t.integer "coden"
    t.integer "busho_id"
    t.integer "kinmu_total"
    t.integer "night_total"
    t.integer "nurce_id"
  end

  create_table "hospital_meetings", force: true do |t|
    t.integer  "busho_id"
    t.date     "month"
    t.integer  "number"
    t.string   "name"
    t.datetime "start"
    t.float    "length",   limit: 24
    t.boolean  "kaigi",               default: true
  end

  create_table "hospital_monthlies", force: true do |t|
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

  create_table "hospital_needs", force: true do |t|
    t.integer "daytype"
    t.integer "busho_id"
    t.integer "role_id"
    t.integer "kinmucode_id"
    t.integer "minimun"
    t.integer "maximum"
  end

  create_table "hospital_nurces", force: true do |t|
    t.string  "name"
    t.integer "number"
    t.integer "busho_id"
    t.integer "shokui_id"
    t.integer "shokushu_id"
    t.integer "kinmukubun_id"
    t.integer "limit_id"
  end

  create_table "hospital_nurces_roles", id: false, force: true do |t|
    t.integer "nurce_id"
    t.integer "role_id"
  end

  create_table "hospital_roles", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "comment"
    t.integer  "bunrui"
    t.boolean  "need"
  end

  create_table "hospital_wants", force: true do |t|
    t.integer "kinmucode_id"
    t.integer "minimum"
    t.integer "maximum"
  end

  create_table "labels", force: true do |t|
    t.string "system"
    t.string "labelid"
    t.string "label"
    t.text   "labeloption"
  end

  create_table "nurces", force: true do |t|
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

  create_table "nurces_roles", id: false, force: true do |t|
    t.integer "nurce_id"
    t.integer "role_id"
  end

  create_table "power_ube_hospital_months", force: true do |t|
    t.date "month"
  end

  create_table "power_ube_hospital_powers", force: true do |t|
    t.date    "date"
    t.integer "month_id"
    t.integer "weather_id"
    t.float   "power01",    limit: 24
    t.float   "power02",    limit: 24
    t.float   "power03",    limit: 24
    t.float   "power04",    limit: 24
    t.float   "power05",    limit: 24
    t.float   "power06",    limit: 24
    t.float   "power07",    limit: 24
    t.float   "power08",    limit: 24
    t.float   "power09",    limit: 24
    t.float   "power10",    limit: 24
    t.float   "power11",    limit: 24
    t.float   "power12",    limit: 24
    t.float   "power13",    limit: 24
    t.float   "power14",    limit: 24
    t.float   "power15",    limit: 24
    t.float   "power16",    limit: 24
    t.float   "power17",    limit: 24
    t.float   "power18",    limit: 24
    t.float   "power19",    limit: 24
    t.float   "power20",    limit: 24
    t.float   "power21",    limit: 24
    t.float   "power22",    limit: 24
    t.float   "power23",    limit: 24
    t.float   "power24",    limit: 24
    t.float   "rev01",      limit: 24
    t.float   "rev02",      limit: 24
    t.float   "rev03",      limit: 24
    t.float   "rev04",      limit: 24
    t.float   "rev05",      limit: 24
    t.float   "rev06",      limit: 24
    t.float   "rev07",      limit: 24
    t.float   "rev08",      limit: 24
    t.float   "rev09",      limit: 24
    t.float   "rev10",      limit: 24
    t.float   "rev11",      limit: 24
    t.float   "rev12",      limit: 24
    t.float   "rev13",      limit: 24
    t.float   "rev14",      limit: 24
    t.float   "rev15",      limit: 24
    t.float   "rev16",      limit: 24
    t.float   "rev17",      limit: 24
    t.float   "rev18",      limit: 24
    t.float   "rev19",      limit: 24
    t.float   "rev20",      limit: 24
    t.float   "rev21",      limit: 24
    t.float   "rev22",      limit: 24
    t.float   "rev23",      limit: 24
    t.float   "rev24",      limit: 24
    t.float   "ave01",      limit: 24
    t.float   "ave02",      limit: 24
    t.float   "ave03",      limit: 24
    t.float   "ave04",      limit: 24
    t.float   "ave05",      limit: 24
    t.float   "ave06",      limit: 24
    t.float   "ave07",      limit: 24
    t.float   "ave08",      limit: 24
    t.float   "ave09",      limit: 24
    t.float   "ave10",      limit: 24
    t.float   "ave11",      limit: 24
    t.float   "ave12",      limit: 24
    t.float   "ave13",      limit: 24
    t.float   "ave14",      limit: 24
    t.float   "ave15",      limit: 24
    t.float   "ave16",      limit: 24
    t.float   "ave17",      limit: 24
    t.float   "ave18",      limit: 24
    t.float   "ave19",      limit: 24
    t.float   "ave20",      limit: 24
    t.float   "ave21",      limit: 24
    t.float   "ave22",      limit: 24
    t.float   "ave23",      limit: 24
    t.float   "ave24",      limit: 24
    t.float   "by_vaper01", limit: 24
    t.float   "by_vaper02", limit: 24
    t.float   "by_vaper03", limit: 24
    t.float   "by_vaper04", limit: 24
    t.float   "by_vaper05", limit: 24
    t.float   "by_vaper06", limit: 24
    t.float   "by_vaper07", limit: 24
    t.float   "by_vaper08", limit: 24
    t.float   "by_vaper09", limit: 24
    t.float   "by_vaper10", limit: 24
    t.float   "by_vaper11", limit: 24
    t.float   "by_vaper12", limit: 24
    t.float   "by_vaper13", limit: 24
    t.float   "by_vaper14", limit: 24
    t.float   "by_vaper15", limit: 24
    t.float   "by_vaper16", limit: 24
    t.float   "by_vaper17", limit: 24
    t.float   "by_vaper18", limit: 24
    t.float   "by_vaper19", limit: 24
    t.float   "by_vaper20", limit: 24
    t.float   "by_vaper21", limit: 24
    t.float   "by_vaper22", limit: 24
    t.float   "by_vaper23", limit: 24
    t.float   "by_vaper24", limit: 24
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "shimada_factories", force: true do |t|
    t.string  "name"
    t.string  "weather_location"
    t.string  "forecast_location"
    t.integer "power_model_id",                    default: 0
    t.float   "revise_threshold",       limit: 24
    t.float   "revise_slope_lower",     limit: 24
    t.float   "revise_slope_higher",    limit: 24
    t.float   "revise_y0",              limit: 24
    t.float   "revise_power_0line",     limit: 24
    t.float   "raw_vaper_threshold",    limit: 24
    t.float   "raw_vaper_slope_lower",  limit: 24
    t.float   "raw_vaper_slope_higher", limit: 24
    t.float   "raw_vaper_y0",           limit: 24
    t.float   "raw_vaper_power_0line",  limit: 24
  end

  create_table "shimada_months", force: true do |t|
    t.date    "month"
    t.integer "shimada_factory_id"
  end

  create_table "shimada_power_by_30mins", force: true do |t|
    t.integer  "shimada_factory_id"
    t.date     "date"
    t.integer  "month_id"
    t.integer  "weather_id"
    t.float    "hour005",            limit: 24
    t.float    "hour01",             limit: 24
    t.float    "hour015",            limit: 24
    t.float    "hour02",             limit: 24
    t.float    "hour025",            limit: 24
    t.float    "hour03",             limit: 24
    t.float    "hour035",            limit: 24
    t.float    "hour04",             limit: 24
    t.float    "hour045",            limit: 24
    t.float    "hour05",             limit: 24
    t.float    "hour055",            limit: 24
    t.float    "hour06",             limit: 24
    t.float    "hour065",            limit: 24
    t.float    "hour07",             limit: 24
    t.float    "hour075",            limit: 24
    t.float    "hour08",             limit: 24
    t.float    "hour085",            limit: 24
    t.float    "hour09",             limit: 24
    t.float    "hour095",            limit: 24
    t.float    "hour10",             limit: 24
    t.float    "hour105",            limit: 24
    t.float    "hour11",             limit: 24
    t.float    "hour115",            limit: 24
    t.float    "hour12",             limit: 24
    t.float    "hour125",            limit: 24
    t.float    "hour13",             limit: 24
    t.float    "hour135",            limit: 24
    t.float    "hour14",             limit: 24
    t.float    "hour145",            limit: 24
    t.float    "hour15",             limit: 24
    t.float    "hour155",            limit: 24
    t.float    "hour16",             limit: 24
    t.float    "hour165",            limit: 24
    t.float    "hour17",             limit: 24
    t.float    "hour175",            limit: 24
    t.float    "hour18",             limit: 24
    t.float    "hour185",            limit: 24
    t.float    "hour19",             limit: 24
    t.float    "hour195",            limit: 24
    t.float    "hour20",             limit: 24
    t.float    "hour205",            limit: 24
    t.float    "hour21",             limit: 24
    t.float    "hour215",            limit: 24
    t.float    "hour22",             limit: 24
    t.float    "hour225",            limit: 24
    t.float    "hour23",             limit: 24
    t.float    "hour235",            limit: 24
    t.float    "hour24",             limit: 24
    t.float    "rev005",             limit: 24
    t.float    "rev01",              limit: 24
    t.float    "rev015",             limit: 24
    t.float    "rev02",              limit: 24
    t.float    "rev025",             limit: 24
    t.float    "rev03",              limit: 24
    t.float    "rev035",             limit: 24
    t.float    "rev04",              limit: 24
    t.float    "rev045",             limit: 24
    t.float    "rev05",              limit: 24
    t.float    "rev055",             limit: 24
    t.float    "rev06",              limit: 24
    t.float    "rev065",             limit: 24
    t.float    "rev07",              limit: 24
    t.float    "rev075",             limit: 24
    t.float    "rev08",              limit: 24
    t.float    "rev085",             limit: 24
    t.float    "rev09",              limit: 24
    t.float    "rev095",             limit: 24
    t.float    "rev10",              limit: 24
    t.float    "rev105",             limit: 24
    t.float    "rev11",              limit: 24
    t.float    "rev115",             limit: 24
    t.float    "rev12",              limit: 24
    t.float    "rev125",             limit: 24
    t.float    "rev13",              limit: 24
    t.float    "rev135",             limit: 24
    t.float    "rev14",              limit: 24
    t.float    "rev145",             limit: 24
    t.float    "rev15",              limit: 24
    t.float    "rev155",             limit: 24
    t.float    "rev16",              limit: 24
    t.float    "rev165",             limit: 24
    t.float    "rev17",              limit: 24
    t.float    "rev175",             limit: 24
    t.float    "rev18",              limit: 24
    t.float    "rev185",             limit: 24
    t.float    "rev19",              limit: 24
    t.float    "rev195",             limit: 24
    t.float    "rev20",              limit: 24
    t.float    "rev205",             limit: 24
    t.float    "rev21",              limit: 24
    t.float    "rev215",             limit: 24
    t.float    "rev22",              limit: 24
    t.float    "rev225",             limit: 24
    t.float    "rev23",              limit: 24
    t.float    "rev235",             limit: 24
    t.float    "rev24",              limit: 24
    t.float    "ave005",             limit: 24
    t.float    "ave01",              limit: 24
    t.float    "ave015",             limit: 24
    t.float    "ave02",              limit: 24
    t.float    "ave025",             limit: 24
    t.float    "ave03",              limit: 24
    t.float    "ave035",             limit: 24
    t.float    "ave04",              limit: 24
    t.float    "ave045",             limit: 24
    t.float    "ave05",              limit: 24
    t.float    "ave055",             limit: 24
    t.float    "ave06",              limit: 24
    t.float    "ave065",             limit: 24
    t.float    "ave07",              limit: 24
    t.float    "ave075",             limit: 24
    t.float    "ave08",              limit: 24
    t.float    "ave085",             limit: 24
    t.float    "ave09",              limit: 24
    t.float    "ave095",             limit: 24
    t.float    "ave10",              limit: 24
    t.float    "ave105",             limit: 24
    t.float    "ave11",              limit: 24
    t.float    "ave115",             limit: 24
    t.float    "ave12",              limit: 24
    t.float    "ave125",             limit: 24
    t.float    "ave13",              limit: 24
    t.float    "ave135",             limit: 24
    t.float    "ave14",              limit: 24
    t.float    "ave145",             limit: 24
    t.float    "ave15",              limit: 24
    t.float    "ave155",             limit: 24
    t.float    "ave16",              limit: 24
    t.float    "ave165",             limit: 24
    t.float    "ave17",              limit: 24
    t.float    "ave175",             limit: 24
    t.float    "ave18",              limit: 24
    t.float    "ave185",             limit: 24
    t.float    "ave19",              limit: 24
    t.float    "ave195",             limit: 24
    t.float    "ave20",              limit: 24
    t.float    "ave205",             limit: 24
    t.float    "ave21",              limit: 24
    t.float    "ave215",             limit: 24
    t.float    "ave22",              limit: 24
    t.float    "ave225",             limit: 24
    t.float    "ave23",              limit: 24
    t.float    "ave235",             limit: 24
    t.float    "ave24",              limit: 24
    t.float    "by_vaper005",        limit: 24
    t.float    "by_vaper01",         limit: 24
    t.float    "by_vaper015",        limit: 24
    t.float    "by_vaper02",         limit: 24
    t.float    "by_vaper025",        limit: 24
    t.float    "by_vaper03",         limit: 24
    t.float    "by_vaper035",        limit: 24
    t.float    "by_vaper04",         limit: 24
    t.float    "by_vaper045",        limit: 24
    t.float    "by_vaper05",         limit: 24
    t.float    "by_vaper055",        limit: 24
    t.float    "by_vaper06",         limit: 24
    t.float    "by_vaper065",        limit: 24
    t.float    "by_vaper07",         limit: 24
    t.float    "by_vaper075",        limit: 24
    t.float    "by_vaper08",         limit: 24
    t.float    "by_vaper085",        limit: 24
    t.float    "by_vaper09",         limit: 24
    t.float    "by_vaper095",        limit: 24
    t.float    "by_vaper10",         limit: 24
    t.float    "by_vaper105",        limit: 24
    t.float    "by_vaper11",         limit: 24
    t.float    "by_vaper115",        limit: 24
    t.float    "by_vaper12",         limit: 24
    t.float    "by_vaper125",        limit: 24
    t.float    "by_vaper13",         limit: 24
    t.float    "by_vaper135",        limit: 24
    t.float    "by_vaper14",         limit: 24
    t.float    "by_vaper145",        limit: 24
    t.float    "by_vaper15",         limit: 24
    t.float    "by_vaper155",        limit: 24
    t.float    "by_vaper16",         limit: 24
    t.float    "by_vaper165",        limit: 24
    t.float    "by_vaper17",         limit: 24
    t.float    "by_vaper175",        limit: 24
    t.float    "by_vaper18",         limit: 24
    t.float    "by_vaper185",        limit: 24
    t.float    "by_vaper19",         limit: 24
    t.float    "by_vaper195",        limit: 24
    t.float    "by_vaper20",         limit: 24
    t.float    "by_vaper205",        limit: 24
    t.float    "by_vaper21",         limit: 24
    t.float    "by_vaper215",        limit: 24
    t.float    "by_vaper22",         limit: 24
    t.float    "by_vaper225",        limit: 24
    t.float    "by_vaper23",         limit: 24
    t.float    "by_vaper235",        limit: 24
    t.float    "by_vaper24",         limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shimada_powers", force: true do |t|
    t.date    "date"
    t.integer "month_id"
    t.float   "hour01",             limit: 24
    t.float   "hour02",             limit: 24
    t.float   "hour03",             limit: 24
    t.float   "hour04",             limit: 24
    t.float   "hour05",             limit: 24
    t.float   "hour06",             limit: 24
    t.float   "hour07",             limit: 24
    t.float   "hour08",             limit: 24
    t.float   "hour09",             limit: 24
    t.float   "hour10",             limit: 24
    t.float   "hour11",             limit: 24
    t.float   "hour12",             limit: 24
    t.float   "hour13",             limit: 24
    t.float   "hour14",             limit: 24
    t.float   "hour15",             limit: 24
    t.float   "hour16",             limit: 24
    t.float   "hour17",             limit: 24
    t.float   "hour18",             limit: 24
    t.float   "hour19",             limit: 24
    t.float   "hour20",             limit: 24
    t.float   "hour21",             limit: 24
    t.float   "hour22",             limit: 24
    t.float   "hour23",             limit: 24
    t.float   "hour24",             limit: 24
    t.integer "weather_id"
    t.float   "rev01",              limit: 24
    t.float   "rev02",              limit: 24
    t.float   "rev03",              limit: 24
    t.float   "rev04",              limit: 24
    t.float   "rev05",              limit: 24
    t.float   "rev06",              limit: 24
    t.float   "rev07",              limit: 24
    t.float   "rev08",              limit: 24
    t.float   "rev09",              limit: 24
    t.float   "rev10",              limit: 24
    t.float   "rev11",              limit: 24
    t.float   "rev12",              limit: 24
    t.float   "rev13",              limit: 24
    t.float   "rev14",              limit: 24
    t.float   "rev15",              limit: 24
    t.float   "rev16",              limit: 24
    t.float   "rev17",              limit: 24
    t.float   "rev18",              limit: 24
    t.float   "rev19",              limit: 24
    t.float   "rev20",              limit: 24
    t.float   "rev21",              limit: 24
    t.float   "rev22",              limit: 24
    t.float   "rev23",              limit: 24
    t.float   "rev24",              limit: 24
    t.float   "ave01",              limit: 24
    t.float   "ave02",              limit: 24
    t.float   "ave03",              limit: 24
    t.float   "ave04",              limit: 24
    t.float   "ave05",              limit: 24
    t.float   "ave06",              limit: 24
    t.float   "ave07",              limit: 24
    t.float   "ave08",              limit: 24
    t.float   "ave09",              limit: 24
    t.float   "ave10",              limit: 24
    t.float   "ave11",              limit: 24
    t.float   "ave12",              limit: 24
    t.float   "ave13",              limit: 24
    t.float   "ave14",              limit: 24
    t.float   "ave15",              limit: 24
    t.float   "ave16",              limit: 24
    t.float   "ave17",              limit: 24
    t.float   "ave18",              limit: 24
    t.float   "ave19",              limit: 24
    t.float   "ave20",              limit: 24
    t.float   "ave21",              limit: 24
    t.float   "ave22",              limit: 24
    t.float   "ave23",              limit: 24
    t.float   "ave24",              limit: 24
    t.string  "shape"
    t.float   "difference00",       limit: 24
    t.float   "difference01",       limit: 24
    t.float   "difference02",       limit: 24
    t.float   "difference03",       limit: 24
    t.float   "difference04",       limit: 24
    t.float   "difference05",       limit: 24
    t.float   "difference06",       limit: 24
    t.float   "difference07",       limit: 24
    t.float   "difference08",       limit: 24
    t.float   "difference09",       limit: 24
    t.float   "difference10",       limit: 24
    t.float   "difference11",       limit: 24
    t.float   "difference12",       limit: 24
    t.float   "difference13",       limit: 24
    t.float   "difference14",       limit: 24
    t.float   "difference15",       limit: 24
    t.float   "difference16",       limit: 24
    t.float   "difference17",       limit: 24
    t.float   "difference18",       limit: 24
    t.float   "difference19",       limit: 24
    t.float   "difference20",       limit: 24
    t.float   "difference21",       limit: 24
    t.float   "difference22",       limit: 24
    t.float   "difference23",       limit: 24
    t.float   "f4_na0",             limit: 24
    t.float   "f4_na1",             limit: 24
    t.float   "f4_na2",             limit: 24
    t.float   "f4_na3",             limit: 24
    t.float   "f4_na4",             limit: 24
    t.float   "f3_x1",              limit: 24
    t.float   "f3_x2",              limit: 24
    t.float   "f3_x3",              limit: 24
    t.float   "f2_x1",              limit: 24
    t.float   "f2_x2",              limit: 24
    t.integer "line"
    t.string  "deform"
    t.float   "hukurosu",           limit: 24
    t.float   "by_vaper01",         limit: 24
    t.float   "by_vaper02",         limit: 24
    t.float   "by_vaper03",         limit: 24
    t.float   "by_vaper04",         limit: 24
    t.float   "by_vaper05",         limit: 24
    t.float   "by_vaper06",         limit: 24
    t.float   "by_vaper07",         limit: 24
    t.float   "by_vaper08",         limit: 24
    t.float   "by_vaper09",         limit: 24
    t.float   "by_vaper10",         limit: 24
    t.float   "by_vaper11",         limit: 24
    t.float   "by_vaper12",         limit: 24
    t.float   "by_vaper13",         limit: 24
    t.float   "by_vaper14",         limit: 24
    t.float   "by_vaper15",         limit: 24
    t.float   "by_vaper16",         limit: 24
    t.float   "by_vaper17",         limit: 24
    t.float   "by_vaper18",         limit: 24
    t.float   "by_vaper19",         limit: 24
    t.float   "by_vaper20",         limit: 24
    t.float   "by_vaper21",         limit: 24
    t.float   "by_vaper22",         limit: 24
    t.float   "by_vaper23",         limit: 24
    t.float   "by_vaper24",         limit: 24
    t.integer "shimada_factory_id"
  end

  create_table "top_pages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ube_change_times", force: true do |t|
    t.text    "ope_name"
    t.text    "ope_type"
    t.integer "change_time"
    t.text    "ope_from"
    t.text    "ope_to"
  end

  create_table "ube_constants", force: true do |t|
    t.text    "name"
    t.integer "value"
    t.text    "comment"
    t.boolean "admin"
    t.text    "keyword"
  end

  create_table "ube_holydays", force: true do |t|
    t.text "month"
    t.text "shozow"
    t.text "shozoe"
    t.text "dryo"
    t.text "dryn"
    t.text "kakou"
  end

  create_table "ube_maintains", force: true do |t|
    t.string   "ope_name"
    t.datetime "plan_time_start"
    t.datetime "plan_time_end"
    t.string   "memo"
    t.text     "maintain_no"
    t.text     "maintain"
  end

  create_table "ube_meigara_shortnames", force: true do |t|
    t.text    "name"
    t.text    "short_name"
    t.integer "ube_meigara_id"
  end

  create_table "ube_meigaras", force: true do |t|
    t.text "meigara"
    t.text "proname"
  end

  create_table "ube_named_changes", force: true do |t|
    t.integer "jun"
    t.integer "pre_condition_id"
    t.integer "post_condition_id"
    t.text    "ope_name"
    t.text    "display"
  end

  create_table "ube_operations", force: true do |t|
    t.text  "ope_name"
    t.float "west",     limit: 24
    t.float "east",     limit: 24
    t.float "old",      limit: 24
    t.float "new",      limit: 24
    t.float "kakou",    limit: 24
  end

  create_table "ube_plans", force: true do |t|
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

  create_table "ube_plans_skds", id: false, force: true do |t|
    t.integer "plan_id"
    t.integer "skd_id"
  end

  create_table "ube_products", force: true do |t|
    t.string  "proname"
    t.string  "shozo"
    t.string  "dryer"
    t.integer "lot_size"
    t.float   "defect_rate",   limit: 24
    t.text    "ope_condition"
    t.text    "color"
    t.boolean "hozen"
    t.integer "roundsize"
  end

  create_table "ube_skds", force: true do |t|
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
    t.datetime "replan_from"
    t.date     "plan_from"
  end

  create_table "ubr_pillars", force: true do |t|
    t.string  "name"
    t.integer "souko_floor_id"
    t.integer "kazu_x"
    t.integer "kazu_y"
    t.float   "start_x",        limit: 24
    t.float   "start_y",        limit: 24
    t.float   "kankaku_x",      limit: 24
    t.float   "kankaku_y",      limit: 24
    t.float   "size_x",         limit: 24
    t.float   "size_y",         limit: 24
  end

  create_table "ubr_souko_floor_souko_plans", force: true do |t|
    t.integer "souko_floor_id"
    t.integer "souko_plan_id"
    t.float   "floor_offset_x", limit: 24
    t.float   "floor_offset_y", limit: 24
  end

  create_table "ubr_souko_floor_waku_blocks", id: false, force: true do |t|
    t.integer "souko_floor_id"
    t.integer "waku_block_id"
  end

  create_table "ubr_souko_floors", force: true do |t|
    t.text  "name"
    t.float "outline_x0", limit: 24
    t.float "outline_y0", limit: 24
    t.float "outline_x1", limit: 24
    t.float "outline_y1", limit: 24
  end

  create_table "ubr_souko_plans", force: true do |t|
    t.text    "name"
    t.text    "stat_name_list"
    t.text    "stat_reg_list"
    t.float   "offset_x",       limit: 24
    t.float   "offset_y",       limit: 24
    t.float   "stat_offset_x",  limit: 24
    t.float   "stat_offset_y",  limit: 24
    t.float   "stat_font",      limit: 24
    t.float   "stat_point",     limit: 24
    t.boolean "landscape"
  end

  create_table "ubr_waku_blocks", force: true do |t|
    t.integer "souko_floor_id"
    t.text    "souko"
    t.text    "content"
    t.text    "sufix"
    t.text    "max"
    t.float   "label_pos_x",    limit: 24
    t.float   "label_pos_y",    limit: 24
    t.float   "base_point_x",   limit: 24
    t.float   "base_point_y",   limit: 24
  end

  create_table "ubr_wakus", force: true do |t|
    t.text    "name"
    t.text    "areaknb"
    t.text    "direct_to"
    t.text    "palette"
    t.integer "volum"
    t.integer "dan3"
    t.integer "dan2"
    t.integer "dan1"
    t.integer "retusu"
    t.float   "pos_x",     limit: 24
    t.float   "pos_y",     limit: 24
  end

  create_table "ubr_walls", force: true do |t|
    t.integer "souko_floor_id"
    t.float   "name",           limit: 24
    t.float   "x0",             limit: 24
    t.float   "y0",             limit: 24
    t.float   "dx1",            limit: 24
    t.float   "dy1",            limit: 24
    t.float   "dx2",            limit: 24
    t.float   "dy2",            limit: 24
    t.float   "dx3",            limit: 24
    t.float   "dy3",            limit: 24
    t.float   "dx4",            limit: 24
    t.float   "dy4",            limit: 24
  end

  create_table "user_option_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "user_option_id"
  end

  create_table "user_options", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "label"
    t.text     "url"
    t.integer  "order"
    t.text     "comment"
    t.text     "authorized"
  end

  create_table "user_options_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "user_option_id"
  end

  create_table "users", force: true do |t|
    t.string   "username",                  limit: 40
    t.string   "name",                      limit: 100, default: ""
    t.string   "email",                     limit: 100
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 40
    t.datetime "remember_token_expires_at"
    t.boolean  "lipscsvio",                             default: false
    t.boolean  "lipssizeoption",                        default: false
    t.integer  "lipssizepro",                           default: 10
    t.integer  "lipssizeope",                           default: 10
    t.string   "lipslabelcode",                         default: "default"
    t.string   "lipsoptlink"
    t.string   "state",                                 default: "passive"
    t.datetime "deleted_at"
    t.string   "subdomain"
    t.datetime "confirmed_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "weather_by_30mins", force: true do |t|
    t.string   "location"
    t.date     "month"
    t.date     "date"
    t.float    "hourhour005",    limit: 24
    t.float    "hourhour010",    limit: 24
    t.float    "hourhour015",    limit: 24
    t.float    "hourhour020",    limit: 24
    t.float    "hourhour025",    limit: 24
    t.float    "hourhour030",    limit: 24
    t.float    "hourhour035",    limit: 24
    t.float    "hourhour040",    limit: 24
    t.float    "hourhour045",    limit: 24
    t.float    "hourhour050",    limit: 24
    t.float    "hourhour055",    limit: 24
    t.float    "hourhour060",    limit: 24
    t.float    "hourhour065",    limit: 24
    t.float    "hourhour070",    limit: 24
    t.float    "hourhour075",    limit: 24
    t.float    "hourhour080",    limit: 24
    t.float    "hourhour085",    limit: 24
    t.float    "hourhour090",    limit: 24
    t.float    "hourhour095",    limit: 24
    t.float    "hourhour100",    limit: 24
    t.float    "hourhour105",    limit: 24
    t.float    "hourhour110",    limit: 24
    t.float    "hourhour115",    limit: 24
    t.float    "hourhour120",    limit: 24
    t.float    "hourhour125",    limit: 24
    t.float    "hourhour130",    limit: 24
    t.float    "hourhour135",    limit: 24
    t.float    "hourhour140",    limit: 24
    t.float    "hourhour145",    limit: 24
    t.float    "hourhour150",    limit: 24
    t.float    "hourhour155",    limit: 24
    t.float    "hourhour160",    limit: 24
    t.float    "hourhour165",    limit: 24
    t.float    "hourhour170",    limit: 24
    t.float    "hourhour175",    limit: 24
    t.float    "hourhour180",    limit: 24
    t.float    "hourhour185",    limit: 24
    t.float    "hourhour190",    limit: 24
    t.float    "hourhour195",    limit: 24
    t.float    "hourhour200",    limit: 24
    t.float    "hourhour205",    limit: 24
    t.float    "hourhour210",    limit: 24
    t.float    "hourhour215",    limit: 24
    t.float    "hourhour220",    limit: 24
    t.float    "hourhour225",    limit: 24
    t.float    "hourhour230",    limit: 24
    t.float    "hourhour235",    limit: 24
    t.float    "hourhour240",    limit: 24
    t.float    "vaperhour005",   limit: 24
    t.float    "vaperhour010",   limit: 24
    t.float    "vaperhour015",   limit: 24
    t.float    "vaperhour020",   limit: 24
    t.float    "vaperhour025",   limit: 24
    t.float    "vaperhour030",   limit: 24
    t.float    "vaperhour035",   limit: 24
    t.float    "vaperhour040",   limit: 24
    t.float    "vaperhour045",   limit: 24
    t.float    "vaperhour050",   limit: 24
    t.float    "vaperhour055",   limit: 24
    t.float    "vaperhour060",   limit: 24
    t.float    "vaperhour065",   limit: 24
    t.float    "vaperhour070",   limit: 24
    t.float    "vaperhour075",   limit: 24
    t.float    "vaperhour080",   limit: 24
    t.float    "vaperhour085",   limit: 24
    t.float    "vaperhour090",   limit: 24
    t.float    "vaperhour095",   limit: 24
    t.float    "vaperhour100",   limit: 24
    t.float    "vaperhour105",   limit: 24
    t.float    "vaperhour110",   limit: 24
    t.float    "vaperhour115",   limit: 24
    t.float    "vaperhour120",   limit: 24
    t.float    "vaperhour125",   limit: 24
    t.float    "vaperhour130",   limit: 24
    t.float    "vaperhour135",   limit: 24
    t.float    "vaperhour140",   limit: 24
    t.float    "vaperhour145",   limit: 24
    t.float    "vaperhour150",   limit: 24
    t.float    "vaperhour155",   limit: 24
    t.float    "vaperhour160",   limit: 24
    t.float    "vaperhour165",   limit: 24
    t.float    "vaperhour170",   limit: 24
    t.float    "vaperhour175",   limit: 24
    t.float    "vaperhour180",   limit: 24
    t.float    "vaperhour185",   limit: 24
    t.float    "vaperhour190",   limit: 24
    t.float    "vaperhour195",   limit: 24
    t.float    "vaperhour200",   limit: 24
    t.float    "vaperhour205",   limit: 24
    t.float    "vaperhour210",   limit: 24
    t.float    "vaperhour215",   limit: 24
    t.float    "vaperhour220",   limit: 24
    t.float    "vaperhour225",   limit: 24
    t.float    "vaperhour230",   limit: 24
    t.float    "vaperhour235",   limit: 24
    t.float    "vaperhour240",   limit: 24
    t.float    "humidithour005", limit: 24
    t.float    "humidithour010", limit: 24
    t.float    "humidithour015", limit: 24
    t.float    "humidithour020", limit: 24
    t.float    "humidithour025", limit: 24
    t.float    "humidithour030", limit: 24
    t.float    "humidithour035", limit: 24
    t.float    "humidithour040", limit: 24
    t.float    "humidithour045", limit: 24
    t.float    "humidithour050", limit: 24
    t.float    "humidithour055", limit: 24
    t.float    "humidithour060", limit: 24
    t.float    "humidithour065", limit: 24
    t.float    "humidithour070", limit: 24
    t.float    "humidithour075", limit: 24
    t.float    "humidithour080", limit: 24
    t.float    "humidithour085", limit: 24
    t.float    "humidithour090", limit: 24
    t.float    "humidithour095", limit: 24
    t.float    "humidithour100", limit: 24
    t.float    "humidithour105", limit: 24
    t.float    "humidithour110", limit: 24
    t.float    "humidithour115", limit: 24
    t.float    "humidithour120", limit: 24
    t.float    "humidithour125", limit: 24
    t.float    "humidithour130", limit: 24
    t.float    "humidithour135", limit: 24
    t.float    "humidithour140", limit: 24
    t.float    "humidithour145", limit: 24
    t.float    "humidithour150", limit: 24
    t.float    "humidithour155", limit: 24
    t.float    "humidithour160", limit: 24
    t.float    "humidithour165", limit: 24
    t.float    "humidithour170", limit: 24
    t.float    "humidithour175", limit: 24
    t.float    "humidithour180", limit: 24
    t.float    "humidithour185", limit: 24
    t.float    "humidithour190", limit: 24
    t.float    "humidithour195", limit: 24
    t.float    "humidithour200", limit: 24
    t.float    "humidithour205", limit: 24
    t.float    "humidithour210", limit: 24
    t.float    "humidithour215", limit: 24
    t.float    "humidithour220", limit: 24
    t.float    "humidithour225", limit: 24
    t.float    "humidithour230", limit: 24
    t.float    "humidithour235", limit: 24
    t.float    "humidithour240", limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weather_locations", force: true do |t|
    t.string  "name"
    t.string  "location"
    t.string  "weather_block"
    t.string  "forecast_code"
    t.string  "excite_zip"
    t.integer "weather_prec"
  end

  create_table "weathers", force: true do |t|
    t.string "location"
    t.date   "date"
    t.float  "hour01",     limit: 24
    t.float  "hour02",     limit: 24
    t.float  "hour03",     limit: 24
    t.float  "hour04",     limit: 24
    t.float  "hour05",     limit: 24
    t.float  "hour06",     limit: 24
    t.float  "hour07",     limit: 24
    t.float  "hour08",     limit: 24
    t.float  "hour09",     limit: 24
    t.float  "hour10",     limit: 24
    t.float  "hour11",     limit: 24
    t.float  "hour12",     limit: 24
    t.float  "hour13",     limit: 24
    t.float  "hour14",     limit: 24
    t.float  "hour15",     limit: 24
    t.float  "hour16",     limit: 24
    t.float  "hour17",     limit: 24
    t.float  "hour18",     limit: 24
    t.float  "hour19",     limit: 24
    t.float  "hour20",     limit: 24
    t.float  "hour21",     limit: 24
    t.float  "hour22",     limit: 24
    t.float  "hour23",     limit: 24
    t.float  "hour24",     limit: 24
    t.date   "month"
    t.float  "vaper01",    limit: 24
    t.float  "vaper02",    limit: 24
    t.float  "vaper03",    limit: 24
    t.float  "vaper04",    limit: 24
    t.float  "vaper05",    limit: 24
    t.float  "vaper06",    limit: 24
    t.float  "vaper07",    limit: 24
    t.float  "vaper08",    limit: 24
    t.float  "vaper09",    limit: 24
    t.float  "vaper10",    limit: 24
    t.float  "vaper11",    limit: 24
    t.float  "vaper12",    limit: 24
    t.float  "vaper13",    limit: 24
    t.float  "vaper14",    limit: 24
    t.float  "vaper15",    limit: 24
    t.float  "vaper16",    limit: 24
    t.float  "vaper17",    limit: 24
    t.float  "vaper18",    limit: 24
    t.float  "vaper19",    limit: 24
    t.float  "vaper20",    limit: 24
    t.float  "vaper21",    limit: 24
    t.float  "vaper22",    limit: 24
    t.float  "vaper23",    limit: 24
    t.float  "vaper24",    limit: 24
    t.float  "humidity01", limit: 24
    t.float  "humidity02", limit: 24
    t.float  "humidity03", limit: 24
    t.float  "humidity04", limit: 24
    t.float  "humidity05", limit: 24
    t.float  "humidity06", limit: 24
    t.float  "humidity07", limit: 24
    t.float  "humidity08", limit: 24
    t.float  "humidity09", limit: 24
    t.float  "humidity10", limit: 24
    t.float  "humidity11", limit: 24
    t.float  "humidity12", limit: 24
    t.float  "humidity13", limit: 24
    t.float  "humidity14", limit: 24
    t.float  "humidity15", limit: 24
    t.float  "humidity16", limit: 24
    t.float  "humidity17", limit: 24
    t.float  "humidity18", limit: 24
    t.float  "humidity19", limit: 24
    t.float  "humidity20", limit: 24
    t.float  "humidity21", limit: 24
    t.float  "humidity22", limit: 24
    t.float  "humidity23", limit: 24
    t.float  "humidity24", limit: 24
  end

end

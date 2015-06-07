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

ActiveRecord::Schema.define(version: 20150607004328) do

  create_table "forecasts", force: :cascade do |t|
    t.string   "location",     limit: 255
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
    t.string   "weather03",    limit: 255
    t.string   "weather06",    limit: 255
    t.string   "weather09",    limit: 255
    t.string   "weather12",    limit: 255
    t.string   "weather15",    limit: 255
    t.string   "weather18",    limit: 255
    t.string   "weather21",    limit: 255
    t.string   "weather24",    limit: 255
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

  create_table "holydays", force: :cascade do |t|
    t.integer "year", limit: 4
    t.date    "day"
    t.string  "name", limit: 255
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "shimada_daylies", force: :cascade do |t|
    t.date     "month"
    t.date     "date"
    t.string   "serial",            limit: 255
    t.string   "ch_name_type",      limit: 255
    t.string   "measurement_type",  limit: 255
    t.text     "measurement_value", limit: 65535
    t.text     "converted_value",   limit: 65535
    t.integer  "instrument_id",     limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "interval",          limit: 4
  end

  create_table "shimada_factories", force: :cascade do |t|
    t.string  "name",                   limit: 255
    t.string  "weather_location",       limit: 255
    t.string  "forecast_location",      limit: 255
    t.integer "power_model_id",         limit: 4,     default: 0
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
    t.text    "prefix",                 limit: 65535
  end

  create_table "shimada_graph_defines", force: :cascade do |t|
    t.integer "factory_id", limit: 4
    t.string  "name",       limit: 255
    t.string  "title",      limit: 255
    t.string  "graph_type", limit: 255
    t.text    "serials",    limit: 65535
  end

  create_table "shimada_instruments", force: :cascade do |t|
    t.string   "serial",           limit: 255
    t.string   "base_name",        limit: 255
    t.string   "ch_name",          limit: 255
    t.string   "measurement",      limit: 255
    t.string   "measurement_type", limit: 255
    t.string   "unit",             limit: 255
    t.string   "comment",          limit: 255
    t.integer  "converter",        limit: 4,   default: 0
    t.float    "slope",            limit: 24,  default: 1.0
    t.float    "graft",            limit: 24,  default: 0.0
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "factory_id",       limit: 4
  end

  create_table "shimada_months", force: :cascade do |t|
    t.date    "month"
    t.integer "shimada_factory_id", limit: 4
  end

  create_table "shimada_power_by_30mins", force: :cascade do |t|
    t.integer  "shimada_factory_id", limit: 4
    t.date     "date"
    t.integer  "month_id",           limit: 4
    t.integer  "weather_id",         limit: 4
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

  create_table "shimada_powers", force: :cascade do |t|
    t.date    "date"
    t.integer "month_id",           limit: 4
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
    t.integer "weather_id",         limit: 4
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
    t.string  "shape",              limit: 255
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
    t.integer "line",               limit: 4
    t.string  "deform",             limit: 255
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
    t.integer "shimada_factory_id", limit: 4
  end

  create_table "sola_daylies", force: :cascade do |t|
    t.date     "month"
    t.date     "date"
    t.string   "base_name",   limit: 255
    t.string   "ch_name",     limit: 255
    t.text     "kws",         limit: 65535
    t.float    "peak_kw",     limit: 24
    t.float    "kwh_day",     limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "kwh_monitor", limit: 24
  end

  create_table "sola_instruments", force: :cascade do |t|
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
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "sola_monthlies", force: :cascade do |t|
    t.date     "month"
    t.string   "base_name",  limit: 255
    t.string   "ch_name",    limit: 255
    t.float    "kwh01",      limit: 24
    t.float    "kwh02",      limit: 24
    t.float    "kwh03",      limit: 24
    t.float    "kwh04",      limit: 24
    t.float    "kwh05",      limit: 24
    t.float    "kwh06",      limit: 24
    t.float    "kwh07",      limit: 24
    t.float    "kwh08",      limit: 24
    t.float    "kwh09",      limit: 24
    t.float    "kwh10",      limit: 24
    t.float    "kwh11",      limit: 24
    t.float    "kwh12",      limit: 24
    t.float    "kwh13",      limit: 24
    t.float    "kwh14",      limit: 24
    t.float    "kwh15",      limit: 24
    t.float    "kwh16",      limit: 24
    t.float    "kwh17",      limit: 24
    t.float    "kwh18",      limit: 24
    t.float    "kwh19",      limit: 24
    t.float    "kwh20",      limit: 24
    t.float    "kwh21",      limit: 24
    t.float    "kwh22",      limit: 24
    t.float    "kwh23",      limit: 24
    t.float    "kwh24",      limit: 24
    t.float    "kwh25",      limit: 24
    t.float    "kwh26",      limit: 24
    t.float    "kwh27",      limit: 24
    t.float    "kwh28",      limit: 24
    t.float    "kwh29",      limit: 24
    t.float    "kwh30",      limit: 24
    t.float    "kwh31",      limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "sum_kwh",    limit: 24
  end

  create_table "status_tand_ds", force: :cascade do |t|
    t.string   "base_name",                    limit: 255
    t.string   "group_name",                   limit: 255
    t.string   "group_remote_name",            limit: 255
    t.string   "group_remote_ch_name",         limit: 255
    t.integer  "group_remote_rssi",            limit: 4
    t.integer  "group_remote_ch_current_batt", limit: 4
    t.integer  "group_remote_ch_record_type",  limit: 4
    t.datetime "group_remote_ch_unix_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "todos", force: :cascade do |t|
    t.string   "status",     limit: 255
    t.string   "task",       limit: 255
    t.string   "title",      limit: 255
    t.string   "branch",     limit: 255
    t.string   "tag",        limit: 255
    t.text     "note",       limit: 65535
    t.text     "measures",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_option_users", id: false, force: :cascade do |t|
    t.integer "user_id",        limit: 4
    t.integer "user_option_id", limit: 4
  end

  create_table "user_options", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "label",      limit: 65535
    t.text     "url",        limit: 65535
    t.integer  "order",      limit: 4
    t.text     "comment",    limit: 65535
    t.text     "authorized", limit: 65535
  end

  create_table "user_options_users", id: false, force: :cascade do |t|
    t.integer "user_id",        limit: 4
    t.integer "user_option_id", limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                  limit: 40
    t.string   "name",                      limit: 100, default: ""
    t.string   "email",                     limit: 100
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 40
    t.datetime "remember_token_expires_at"
    t.boolean  "lipscsvio",                 limit: 1,   default: false
    t.boolean  "lipssizeoption",            limit: 1,   default: false
    t.integer  "lipssizepro",               limit: 4,   default: 10
    t.integer  "lipssizeope",               limit: 4,   default: 10
    t.string   "lipslabelcode",             limit: 255, default: "default"
    t.string   "lipsoptlink",               limit: 255
    t.string   "state",                     limit: 255, default: "passive"
    t.datetime "deleted_at"
    t.string   "subdomain",                 limit: 255
    t.datetime "confirmed_at"
    t.string   "reset_password_token",      limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             limit: 4,   default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",        limit: 255
    t.string   "last_sign_in_ip",           limit: 255
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "weather_by_30mins", force: :cascade do |t|
    t.string   "location",       limit: 255
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

  create_table "weather_locations", force: :cascade do |t|
    t.string  "name",          limit: 255
    t.string  "location",      limit: 255
    t.string  "weather_block", limit: 255
    t.string  "forecast_code", limit: 255
    t.string  "excite_zip",    limit: 255
    t.integer "weather_prec",  limit: 4
  end

  create_table "weathers", force: :cascade do |t|
    t.string "location",   limit: 255
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
    t.text   "temp",       limit: 65535
    t.text   "vaper",      limit: 65535
    t.text   "humi",       limit: 65535
  end

end

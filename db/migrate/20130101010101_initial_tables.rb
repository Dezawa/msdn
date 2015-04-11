# encoding: UTF-8
class InitialTables < ActiveRecord::Migration
  def change
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
      t.text    "prefix"
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

    create_table "sola_daylies", force: true do |t|
      t.date     "month"
      t.date     "date"
      t.string   "base_name"
      t.string   "ch_name"
      t.text     "kws"
      t.float    "peak_kw",     limit: 24
      t.float    "kwh_day",     limit: 24
      t.datetime "created_at"
      t.datetime "updated_at"
      t.float    "kwh_monitor", limit: 24
      t.text     "volts"
    end

    create_table "sola_monthlies", force: true do |t|
      t.date     "month"
      t.string   "base_name"
      t.string   "ch_name"
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

    create_table "status_tand_ds", force: true do |t|
      t.string   "base_name"
      t.string   "group_name"
      t.string   "group_remote_name"
      t.string   "group_remote_ch_name"
      t.integer  "group_remote_rssi"
      t.integer  "group_remote_ch_current_batt"
      t.integer  "group_remote_ch_record_type"
      t.datetime "group_remote_ch_unix_time"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "todos", force: true do |t|
      t.string   "status"
      t.string   "task"
      t.string   "title"
      t.string   "branch"
      t.string   "tag"
      t.text     "note"
      t.text     "measures"
      t.datetime "created_at"
      t.datetime "updated_at"
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
end

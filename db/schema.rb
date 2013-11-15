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

ActiveRecord::Schema.define(version: 20131011205611) do

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

  create_table "holydays", force: true do |t|
    t.integer "year"
    t.date    "day"
    t.string  "name"
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
    t.float   "am",              default: 0.0
    t.float   "night",           default: 0.0
    t.float   "midnight",        default: 0.0
    t.float   "am2",             default: 0.0
    t.float   "night2",          default: 0.0
    t.float   "midnight2",       default: 0.0
    t.float   "nenkyuu"
    t.float   "pm",              default: 0.0
    t.float   "pm2",             default: 0.0
  end

  create_table "hospital_limits", force: true do |t|
    t.integer "code0"
    t.integer "code1"
    t.integer "code2"
    t.integer "code3"
    t.integer "coden"
    t.integer "busho_id"
  end

  create_table "hospital_meetings", force: true do |t|
    t.integer  "busho_id"
    t.date     "month"
    t.integer  "number"
    t.string   "name"
    t.datetime "start"
    t.float    "length"
    t.boolean  "kaigi",    default: true
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

  create_table "hospital_roles", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "comment"
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
    t.integer "shokui_id"
    t.integer "shokushu_id"
    t.integer "kinmukubun_id"
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
    t.float "west"
    t.float "east"
    t.float "old"
    t.float "new"
    t.float "kakou"
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

  create_table "ube_plans_ube_skds", id: false, force: true do |t|
    t.integer "ube_plan_id"
    t.integer "ube_skd_id"
  end

  create_table "ube_products", force: true do |t|
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
    t.date     "plan_from"
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
    t.string   "email",                  limit: 100
    t.string   "encrypted_password",                 default: "",        null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",                  limit: 40
    t.string   "name",                   limit: 100, default: ""
    t.string   "crypted_password",       limit: 40
    t.string   "salt",                   limit: 40
    t.boolean  "lipscsvio",                          default: false
    t.boolean  "lipssizeoption",                     default: false
    t.integer  "lipssizepro",                        default: 10
    t.integer  "lipssizeope",                        default: 10
    t.string   "lipslabelcode",                      default: "default"
    t.string   "lipsoptlink"
    t.string   "state",                              default: "passive"
    t.datetime "deleted_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

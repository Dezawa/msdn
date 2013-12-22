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

ActiveRecord::Schema.define(version: 20131214002521) do

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

  create_table "holydays", force: true do |t|
    t.integer "year"
    t.date    "day"
    t.string  "name"
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

  create_table "ube_plans_skds", id: false, force: true do |t|
    t.integer "plan_id"
    t.integer "skd_id"
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
    t.datetime "replan_from"
    t.date     "plan_from"
  end

  create_table "user_options", force: true do |t|
    t.text    "label"
    t.text    "url"
    t.integer "order"
    t.text    "comment"
    t.text    "authorized"
  end

  create_table "user_options_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "user_option_id"
  end

  create_table "users", force: true do |t|
    t.string   "email",                              default: "",        null: false
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
    t.string   "username",               limit: 40
    t.string   "name",                   limit: 100, default: ""
    t.boolean  "lipscsvio",                          default: false
    t.boolean  "lipssizeoption",                     default: false
    t.integer  "lipssizepro",                        default: 10
    t.integer  "lipssizeope",                        default: 10
    t.string   "lipslabelcode",                      default: "default"
    t.string   "lipsoptlink"
    t.string   "state",                              default: "passive"
    t.datetime "deleted_at"
    t.string   "subdomain"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

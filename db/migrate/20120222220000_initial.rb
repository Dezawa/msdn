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

class Initial < ActiveRecord::Migration

  create_table "book_kamokus", :force => true do |t|
    t.text "kamoku"
    t.text "bunrui"
  end

  create_table "book_mains", :force => true do |t|
    t.integer "no"
    t.date    "date"
    t.integer "kasikata"
    t.integer "karikata"
    t.text    "tytle"
    t.text    "memo"
    t.integer "amount"
  end

  create_table "labels", :force => true do |t|
    t.string "system"
    t.string "labelid"
    t.string "label"
    t.text   "labeloption"
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

  create_table "ube_meigaras", :force => true do |t|
    t.text "meigara"
    t.text "proname"
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
  end

  create_table "user_options", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "label"
    t.text     "url"
    t.integer  "order"
    t.text     "comment"
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
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end

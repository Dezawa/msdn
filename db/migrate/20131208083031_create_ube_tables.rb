class CreateUbeTables < ActiveRecord::Migration
  def change
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
      t.datetime "replan_from"
      t.date     "plan_from"
    end
  end
end


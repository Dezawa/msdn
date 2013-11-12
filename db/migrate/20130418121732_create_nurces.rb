class CreateNurces < ActiveRecord::Migration
  def self.up
  create_table "nurces", :force => true do |t|
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
  end

  def self.down
  end
end

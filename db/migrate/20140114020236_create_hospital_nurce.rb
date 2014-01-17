class CreateHospitalNurce < ActiveRecord::Migration
  def change
    create_table :hospital_nurces do |t|
    t.string  "name"
    t.integer "number"
    t.integer "busho_id"
    t.integer "shokui_id"
    t.integer "shokushu_id"
    t.integer "kinmukubun_id"
    t.integer "limit_id"
    end
  end
end

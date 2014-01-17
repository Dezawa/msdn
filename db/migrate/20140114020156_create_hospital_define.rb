class CreateHospitalDefine < ActiveRecord::Migration
  def change
    create_table :hospital_defines do |t|
      t.string "name"
      t.string "attri"
      t.string "value"
      t.string "comment"
    end
  end
end

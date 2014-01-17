class CreateHospitalRole < ActiveRecord::Migration
  def change
    create_table :hospital_roles do |t|
    t.string   "name"
    t.string   "comment"
    end
  end
end

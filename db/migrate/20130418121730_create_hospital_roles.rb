class CreateHospitalRoles < ActiveRecord::Migration
  def self.up
    create_table "hospital_roles", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.string   "comment"
    end
  end

  def self.down
  end
end

class CreateHospitalNeeds < ActiveRecord::Migration
  def self.up
    create_table "hospital_needs", :force => true do |t|
      t.integer "daytype"
      t.integer "busho_id"
      t.integer "role_id"
      t.integer "kinmucode_id"
      t.integer "minimun"
      t.integer "maximum"
    end
  end

  def self.down
  end
end

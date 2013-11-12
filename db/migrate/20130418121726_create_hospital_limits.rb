class CreateHospitalLimits < ActiveRecord::Migration
  def self.up
    create_table "hospital_limits", :force => true do |t|
      t.integer "code0"
      t.integer "code1"
      t.integer "code2"
      t.integer "code3"
      t.integer "coden"
      t.integer "busho_id"
    end
  end

  def self.down
  end
end

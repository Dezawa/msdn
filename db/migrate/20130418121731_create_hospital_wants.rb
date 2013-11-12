class CreateHospitalWants < ActiveRecord::Migration
  def self.up
    create_table "hospital_wants", :force => true do |t|
      t.integer "kinmucode_id"
      t.integer "minimum"
      t.integer "maximum"
    end
  end

  def self.down
  end
end

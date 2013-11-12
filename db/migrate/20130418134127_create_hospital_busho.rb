class CreateHospitalBusho < ActiveRecord::Migration
  def self.up
create_table "bushos", :force => true do |t|
    t.string "name"
  end


  end

  def self.down
  end
end

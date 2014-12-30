class CreateHospitalDefines < ActiveRecord::Migration
  def self.up
    create_table "hospital_defines", :force => true do |t|
      t.string :name
      t.string :attri
      t.string :value
      t.string :comment
    end
  end

  def self.down
  end
end

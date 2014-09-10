class CreateHospitalAvoidCombination < ActiveRecord::Migration
  
  def self.up
    create_table :hospital_avoid_combinations do |t|
      t.integer :busho_id
      t.integer :nurce1_id
      t.integer :nurce2_id
      t.integer :weight      
    end
  end

  def self.down
    drop_table :hospital_avoid_combinations
  end
end

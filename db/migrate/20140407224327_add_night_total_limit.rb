class AddNightTotalLimit < ActiveRecord::Migration
  def self.up
    add_column :hospital_limits,:kinmu_total,:integer
    add_column :hospital_limits,:night_total,:integer
  end

  def self.down
    remove_column :hospital_limits,:kinmu_total
    remove_column :hospital_limits,:night_total
  end
end

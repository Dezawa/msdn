class CreateUbrSoukoFloorSoukoPlan < ActiveRecord::Migration
  def self.up
    create_table :ubr_souko_floor_souko_plans do |t|
      [:souko_floor_id,:souko_plan_id].each{ |sym| t.integer sym}
      [:floor_offset_x,:floor_offset_y ].each{ |sym| t.float sym}
    end
  end

  def self.down
  end
end

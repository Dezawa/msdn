class CreateUbrSoukoFloorWakuBlocks < ActiveRecord::Migration
  def self.up
    create_table :ubr_souko_floor_waku_blocks,:id => false do |t|
      [:souko_floor_id,:waku_block_id].each{ |sym| t.integer sym}
    end
  end

  def self.down
    drop_table :ubr_souko_plan_waku_blocks
  end
end

class CreateUbrWakuBlocks < ActiveRecord::Migration
  def self.up
    create_table :ubr_waku_blocks do |t|
      t.integer :souko_floor_id
      [:souko,:content,:sufix,:max].each{ |sym| t.text sym}
      [:label_pos_x,:label_pos_y,:base_point_x,:base_point_y].
        each{ |sym| t.float sym}
    end
  end

  def self.down
    drop_table :ubr_waku_blocks
  end
end

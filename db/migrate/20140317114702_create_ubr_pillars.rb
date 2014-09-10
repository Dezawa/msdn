class CreateUbrPillars < ActiveRecord::Migration
  def self.up
    create_table :ubr_pillars do |t|
      t.string :name
      [:souko_floor_id,:kazu_x, :kazu_y].each{ |s| t.integer s}
      [:start_x,:start_y,:kankaku_x,:kankaku_y,:size_x,:size_y].
        each{ |s| t.float s}
    end
  end

  def self.down
    drop_table :ubr_pillars
  end
end

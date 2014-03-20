class CreateUbrWalls < ActiveRecord::Migration
  def self.up
    create_table :ubr_walls do |t|
      t.integer :souko_floor_id
      t.string
      %w(name x0 y0 dx1 dy1 dx2 dy2 dx3 dy3 dx4 dy4).each{ |sym|
        t.float sym
      }
    end
  end

  def self.down
    drop_table :ubr_walls
  end
end

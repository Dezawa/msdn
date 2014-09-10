class CreateUbrSoukoFllor < ActiveRecord::Migration
  def self.up
    create_table :ubr_souko_floors do |t|
      t.text :name
      [:outline_x0,:outline_y0,:outline_x1,:outline_y1].each{ |sym| t.float sym} 
    end

  end

  def self.down
  end
end

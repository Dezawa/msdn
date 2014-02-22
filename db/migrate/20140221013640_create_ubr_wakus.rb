class CreateUbrWakus < ActiveRecord::Migration
  def self.up
    create_table :ubr_wakus do |t|
      [:name,:areaknb,:direct_to,:palette].each{ |attr| t.text attr}
      [:volum,:dan3,:dan2,:dan1,:retusu].each{ |attr| t.integer attr}
      [:pos_x,:pos_y].each{ |attr| t.float attr}
    end
  end

  def self.down
    drop_table :ubr_wakus
  end
end

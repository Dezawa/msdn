class CreateWeathers < ActiveRecord::Migration
  def self.up
    create_table :weathers do |t|
      t.string :location
      t.date   :date
      ("temp01".."temp24").each{ |sym| t.float sym}
    end
  end

  def self.down
    drop_table :weathers
  end
end

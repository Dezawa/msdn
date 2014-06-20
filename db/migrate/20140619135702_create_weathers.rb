class CreateWeathers < ActiveRecord::Migration
  def self.up
    create_table :weathers do |t|
      t.string :location
      t.date   :date
      ("hour01".."hour24").each{ |sym| t.float sym}
    end
  end

  def self.down
    drop_table :weathers
  end
end

class AddAveToPower < ActiveRecord::Migration
  def self.up
    ("ave01".."ave24").each{ |rev|
      add_column :shimada_powers,rev,:float 
    }
  end

  def self.down
    ("ave01".."ave24").each{ |rev|
      drop_column :shimada_powers,rev
    }
  end
end

class AddRevesToShimadaPower < ActiveRecord::Migration
  def self.up
    ("rev01".."rev24").each{ |rev|
      add_column :shimada_powers,rev,:float 
    }
  end

  def self.down
    ("rev01".."rev24").each{ |rev|
      drop_column :shimada_powers,rev
    }
  end
end

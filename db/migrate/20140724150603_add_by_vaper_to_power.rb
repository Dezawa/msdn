class AddByVaperToPower < ActiveRecord::Migration
  def self.up
    ("by_vaper01".."by_vaper24").each{ |by_vaper|
      add_column :shimada_powers,by_vaper,:float 
    }
  end

  def self.down
    ("by_vaper01".."by_vaper24").each{ |by_vaper|
      drop_column :shimada_powers,by_vaper
    }
  end
end

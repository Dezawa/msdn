class AddColumn2shimada < ActiveRecord::Migration
  def change
    add_column :shimada_instruments, :factory_id, :integer  
  end
end

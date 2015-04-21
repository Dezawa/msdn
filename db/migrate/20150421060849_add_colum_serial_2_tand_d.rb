class AddColumSerial2TandD < ActiveRecord::Migration
  def change
    add_column :status_tand_ds , :serial ,:string
  end
end

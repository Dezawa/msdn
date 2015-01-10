class RenameTableStatusOndotori < ActiveRecord::Migration
  def change
    rename_table :status_ondotoris,:status_tand_ds
  end
end

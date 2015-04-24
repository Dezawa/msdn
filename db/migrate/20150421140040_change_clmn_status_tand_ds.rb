class ChangeClmnStatusTandDs < ActiveRecord::Migration
  def change
    change_column :status_tand_ds,:group_remote_ch_record_type,:string
  end
end

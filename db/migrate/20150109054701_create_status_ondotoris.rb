class CreateStatusOndotoris < ActiveRecord::Migration
  def change
    create_table :status_ondotoris do |t|
      [ :base_name, :group_name, :group_remote_name,:group_remote_ch_name
      ].each{ |sym| t.string sym }
      [ :group_remote_rssi,:group_remote_ch_current_batt, :group_remote_ch_record_type
      ].each{ |sym| t.integer sym }
      t.datetime :group_remote_ch_unix_time
      t.timestamps
    end
  end
end

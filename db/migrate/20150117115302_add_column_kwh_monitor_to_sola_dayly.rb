class AddColumnKwhMonitorToSolaDayly < ActiveRecord::Migration
  def change
    add_column :sola_daylies,:kwh_monitor,:float
  end
end

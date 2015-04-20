class AddColumSolaDayly < ActiveRecord::Migration
  def change
    add_column :sola_daylies, "serial", :string
    add_column :sola_daylies, :instrument_id,:integer
    add_column :sola_daylies, :measurement_type, :string
    rename_column :sola_daylies, :ch_name,:ch_name_type
  end
end

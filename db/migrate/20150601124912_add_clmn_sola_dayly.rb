class AddClmnSolaDayly < ActiveRecord::Migration
  def change
    add_column :sola_daylies,:serial,:string
    add_column :sola_daylies,:measurement_type,:string
    add_column :sola_daylies,:measurement_value, :text ,limit: 65535
    add_column :sola_daylies,:converted_value,   :text ,limit: 65535
    add_column :sola_daylies,:instrument_id,     :integer
    add_column :sola_daylies,:interval,          :integer
    add_column :sola_daylies,:ch_name_type,:string
  end
end

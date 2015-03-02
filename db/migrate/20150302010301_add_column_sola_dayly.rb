class AddColumnSolaDayly < ActiveRecord::Migration
  def change
    add_column :sola_daylies,:volts,:text
  end
end

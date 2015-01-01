class AddColumnSumToSola < ActiveRecord::Migration
  def change
    add_column :sola_monthlies,:sum_kwh,:float
  end
end

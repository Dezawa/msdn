class CreateSolaMonthlies < ActiveRecord::Migration
  def change
    create_table :sola_monthlies do |t|
      t.date    :month
      t.string  :base_name
      t.string  :ch_name
      ("kwh01".."kwh31").each{ |kwh| t.float kwh }
      t.timestamps
    end
  end
end

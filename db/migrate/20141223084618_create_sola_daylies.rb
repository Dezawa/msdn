class CreateSolaDaylies < ActiveRecord::Migration
  def change
    create_table :sola_daylies do |t|
      t.date    :month
      t.date    :date
      t.string  :base_name
      t.string  :ch_name
      t.text    :kws ,  :limit => 10000   # serialize
      t.float   :peak_kw
      t.float   :kwh_day
      t.timestamps
    end
  end
end

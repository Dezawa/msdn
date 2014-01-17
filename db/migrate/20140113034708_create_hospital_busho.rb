class CreateHospitalBusho < ActiveRecord::Migration
  def change
    create_table :hospital_bushos do |t|
      t.string "name"
    end
  end
end

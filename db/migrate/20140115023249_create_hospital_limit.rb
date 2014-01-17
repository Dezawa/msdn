class CreateHospitalLimit < ActiveRecord::Migration
  def change
    create_table :hospital_limits do |t|
      t.integer "code0"
      t.integer "code1"
      t.integer "code2"
      t.integer "code3"
      t.integer "coden"
      t.integer "busho_id"
    end
  end
end

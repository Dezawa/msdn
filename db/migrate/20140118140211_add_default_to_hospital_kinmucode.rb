class AddDefaultToHospitalKinmucode < ActiveRecord::Migration
  def change
    change_column(:hospital_kinmucodes, :nenkyuu, :float, default: 0.0)
  end
end

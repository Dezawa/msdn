class CreateUbrSoukoPlans < ActiveRecord::Migration
  def self.up
    create_table :ubr_souko_plans do |t|
      [:name,:stat_name_list,:stat_reg_list].each{ |sym| t.text sym}
      [:offset_x,:offset_y , :stat_offset_x, :stat_offset_y, :stat_font, :stat_point].each{ |sym| t.float sym}
      t.boolean :landscape
    end
  end

  def self.down
  end
end

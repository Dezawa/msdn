class AddPlanFrom < ActiveRecord::Migration
  def self.up
    add_column :ube_skds, :plan_from, :date
  end

  def self.down
    drop_colmn :ube_skds, :plan_from
  end
end

class RenameColumnUbePlanSkd < ActiveRecord::Migration
  def change
    rename_column :ube_plans_skds,:ube_skd_id,:skd_id
    rename_column :ube_plans_skds,:ube_plan_id,:plan_id
  end
end

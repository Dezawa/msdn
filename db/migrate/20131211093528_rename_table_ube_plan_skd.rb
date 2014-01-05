class RenameTableUbePlanSkd < ActiveRecord::Migration
  def change
    rename_table :ube_plans_ube_skds,:ube_plans_skds
  end
end

class CreateNurcesRoles < ActiveRecord::Migration
  def change
    create_table :nurces_roles, :id => false do |t|
      t.integer "nurce_id"
      t.integer "role_id"
    end
  end
end

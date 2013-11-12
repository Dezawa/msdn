class CreateNurcesRoles < ActiveRecord::Migration
  def self.up 
    create_table "nurces_roles", :id => false, :force => true do |t|
      t.integer "nurce_id"
      t.integer "role_id"
    end
  end

  def self.down
  end
end

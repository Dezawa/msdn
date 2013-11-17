class AddColmnUser < ActiveRecord::Migration
  def change
    add_column :users, "login",          :string  ,  :limit => 40
    add_column :users, "name",           :string  ,  :limit => 100, :default => ""
    add_column :users, "lipscsvio",      :boolean ,  :default => false
    add_column :users,  "lipssizeoption",:boolean ,  :default => false
    add_column :users,  "lipssizepro",   :integer ,  :default => 10
    add_column :users,  "lipssizeope",   :integer ,  :default => 10
    add_column :users,  "lipslabelcode", :string  ,  :default => "default"
    add_column :users,  "lipsoptlink",   :string  
    add_column :users,  "state",         :string  ,  :default => "passive"
    add_column :users,  "deleted_at" ,   :datetime
  end
end

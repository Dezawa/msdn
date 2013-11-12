class AddAuthToUserOption < ActiveRecord::Migration
  def self.up
    add_column :users, :state, :string, :null => :no, :default => 'passive'
    add_column :users, :deleted_at,   :datetime
  end

  def self.down
    drop_colmn :state, :deleted_at
  end
end

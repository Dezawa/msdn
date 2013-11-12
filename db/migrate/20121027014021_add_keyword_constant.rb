class AddKeywordConstant < ActiveRecord::Migration
  def self.up
    add_column :ube_constants,:keyword,:text
  end

  def self.down
    drop_column :ube_constants,:keyword
  end
end

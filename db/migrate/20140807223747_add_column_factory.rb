class AddColumnFactory < ActiveRecord::Migration
  def self.up
    add_column :shimada_factories,:forecast_location,:string
  end

  def self.down
    remove_column :shimada_factories,:forecast_location
  end
end

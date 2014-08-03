class AddFactoryToMonthAndPower < ActiveRecord::Migration
  def self.up
    add_column :shimada_months,:shimada_factory_id,:integer
    add_column :shimada_powers,:shimada_factory_id,:integer
  end

  def self.down
    remove_column :shimada_months,:shimada_factory_id,:integer
    remove_column :shimada_powers,:shimada_factory_id,:integer

  end
end

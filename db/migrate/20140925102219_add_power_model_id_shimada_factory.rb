class AddPowerModelIdShimadaFactory < ActiveRecord::Migration
  def change
    add_column :shimada_factories,:power_model_id,:integer,:default => 0
  end
end

class AddParamsShimadaFactory < ActiveRecord::Migration
  def change
    %w(revise_threshold revise_slope_lower revise_slope_higher revise_y0 revise_power_0line).
      each{ |clmn| add_column :shimada_factories,clmn,:float}
  end
end

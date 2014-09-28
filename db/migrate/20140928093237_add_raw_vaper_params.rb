class AddRawVaperParams < ActiveRecord::Migration
  def change
    %w(raw_vaper_threshold raw_vaper_slope_lower raw_vaper_slope_higher raw_vaper_y0 raw_vaper_power_0line).
      each{ |clmn| add_column :shimada_factories,clmn,:float}
  end
end

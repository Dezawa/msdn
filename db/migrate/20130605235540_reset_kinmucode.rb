class ResetKinmucode < ActiveRecord::Migration
  def self.up
    [:am,:pm,:am2,:pm2,:night,:midnight,:night2,:midnight2].each{|sym|
    change_column :hospital_kinmucodes,sym,:float,:default =>0.0
    }
  end

  def self.down
  end
end

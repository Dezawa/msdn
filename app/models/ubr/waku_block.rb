class Ubr::WakuBlock < ActiveRecord::Base
  extend Function::CsvIo
  case RAILS_GEM_VERSION
  when /^2/ ;set_table_name :ubr_waku_blocks
  when /^[34]/ ; self.tabele_name =  'ubr_waku_blocks'
  end
  delegate :logger, :to=>"ActiveRecord::Base"

  def self.[](key)
    self.find(:all,:conditions => ["souko = ?",key])
  end

  def base_point  ; [base_point_x ,base_point_y]  ;end
  def label_pos   ; [label_pos_x  ,label_pos_y]   ;end


end

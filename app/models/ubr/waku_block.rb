class Ubr::WakuBlock < ActiveRecord::Base
  extend Function::CsvIo
  case RAILS_GEM_VERSION
  when /^2/ ;set_table_name :ubr_waku_blocks
  when /^[34]/ ; self.tabele_name =  'ubr_waku_blocks'
  end
  delegate :logger, :to=>"ActiveRecord::Base"

    #has_one    :souko_plan_waku_blocks,:class_name => "Ubr::SoukoFloorWakuBlock",:dependent => :destroy
    #has_one    :souko_floor,:class_name => "Ubr::SoukoFloor", :through => :souko_plan_waku_blocks
  belongs_to  :souko_floor,:class_name => "Ubr::SoukoFloor"

  def self.[](key)
    self.find(:all,:conditions => ["souko = ?",key])
  end

  def base_point  ; [base_point_x||0.0  ,base_point_y||0.0 ]  ;end
  def label_pos   ; [label_pos_x ||0.0  ,label_pos_y ||0.0 ]   ;end


end

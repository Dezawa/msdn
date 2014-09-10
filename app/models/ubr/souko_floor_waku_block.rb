class Ubr::SoukoFloorWakuBlock < ActiveRecord::Base
  extend CsvIo
  self.table_name = "ubr_souko_floor_waku_blocks"
  
    belongs_to :souko_floor,:class_name => "Ubr::SoukoFloor"
    belongs_to :wakublock,:class_name => "Ubr::WakuBlock"
end

class Ubr::SoukoPlanWakuBlock < ActiveRecord::Base
  extend Function::CsvIo
  set_table_name :ubr_souko_plan_waku_blocks
  
  belongs_to :ubr_soukoplan
  belongs_to :ubr_wakublock
end

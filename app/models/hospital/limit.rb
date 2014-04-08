class Hospital::Limit < ActiveRecord::Base
  extend Function::CsvIo
  set_table_name 'hospital_limits'
  Code = [:code0,:code1,:code2,:code3,:coden]
  
  def after_find
    self.kinmu_total = 31 - code0 - coden unless kinmu_total# && kinmu_total>0
  end

end

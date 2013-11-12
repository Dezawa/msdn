class Hospital::Limit < ActiveRecord::Base
  extend Function::CsvIo
  set_table_name 'hospital_limits'
  Code = [:code0,:code1,:code2,:code3,:coden]
  
end

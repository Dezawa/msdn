class Hospital::Limit < ActiveRecord::Base
  extend CsvIo
  
  has_one :nurce , :class_name => "Hospital::Nurce"

  self.table_name = 'hospital_limits'
  Code = [:code0,:code1,:code2,:code3,:coden]
end

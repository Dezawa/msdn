class Hospital::Limit < ActiveRecord::Base
  extend CsvIo
  
  belongs_to :nurce , :class_name => "Hospital::Nurce"

  self.table_name = 'hospital_limits'
  Code = [:code0,:code1,:code2,:code3,:coden]
end

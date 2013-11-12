class Hospital::Want < ActiveRecord::Base
  extend Function::CsvIo
  set_table_name 'hospital_wants'
end

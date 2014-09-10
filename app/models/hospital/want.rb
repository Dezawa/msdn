class Hospital::Want < ActiveRecord::Base
  extend CsvIo
  table_name =  'hospital_wants'
end

class Hospital::Busho < ActiveRecord::Base
  extend CsvIo
  self.table_name = 'hospital_bushos'
  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end
end

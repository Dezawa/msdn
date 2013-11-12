class Hospital::Busho < ActiveRecord::Base
  extend Function::CsvIo
  set_table_name 'bushos'
  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end
end

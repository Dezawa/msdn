class Hospital::Busho < ActiveRecord::Base
  extend CsvIo

  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end
end

class Hospital::Role < ActiveRecord::Base
  extend Function::CsvIo
  has_and_belongs_to_many :nurces
  set_table_name 'hospital_roles'
  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end
end

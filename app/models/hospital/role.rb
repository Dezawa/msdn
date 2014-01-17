class Hospital::Role < ActiveRecord::Base
  extend CsvIo
  has_and_belongs_to_many :nurces
  self.table_name = 'hospital_roles'
  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end
end

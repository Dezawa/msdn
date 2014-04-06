class Hospital::Role < ActiveRecord::Base
  extend Function::CsvIo
  include Hospital::Const
  has_and_belongs_to_many :nurces
  set_table_name 'hospital_roles'

  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end

  def self.shokui
    all(:conditions => "bunrui = 1").map{ |obj| [obj.name,obj.id]}
  end
  def self.shokushu
    all(:conditions => "bunrui = 2").map{ |obj| [obj.name,obj.id]}
  end
  def self.kinmukubun
    all(:conditions => "bunrui = 3").map{ |obj| [obj.name,obj.id]}
  end


  def self.by_shokushu_id(shokushu_id)
    self.find_by_name(Shokushu.rassoc(shokushu_id)[0])
  end

end

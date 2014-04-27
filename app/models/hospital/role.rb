class Hospital::Role < ActiveRecord::Base
  set_table_name 'hospital_roles'

  extend Function::CsvIo
#  include Hospital::Const
  has_and_belongs_to_many :nurces

  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end

  @@name2id =nil
  def self.name2id
   @@name2id ||=  Hash[*all.map{|obj| [obj.name,obj.id]}.flatten]
  end

  @@id2name = nil 
  def self.id2name
    @@id2name ||= Hash[*all.map{|obj| [obj.id,obj.name]}.flatten]
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
  include Hospital::Const
  #logger.debug " [ Kangoshi,Leader ] = [#{ Kangoshi},#{Leader} #{MarginLimit}]"

end

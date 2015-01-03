class Sola::Monthly < ActiveRecord::Base
  include Sola::Graph
  extend CsvIo
  before_save :set_culc
  private
  def set_culc
    self.sum_kwh = ("kwh01".."kwh31").inject(0.0){ |sum,v|  sum += (self[v] || 0.0)}
  end  
end

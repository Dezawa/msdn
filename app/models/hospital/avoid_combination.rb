class Hospital::AvoidCombination < ActiveRecord::Base
  extend Function::CsvIo
  set_table_name 'hospital_avoid_combinations'

  def self.aboid_list 
    @aboid_list ||= self.all.map{ |ab| [ab.nurce1_id,ab.nurce2_id]}
  end
end

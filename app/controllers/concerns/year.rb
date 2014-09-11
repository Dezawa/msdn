class Year
  #attr_accessor :year
  def initialize(date)
    @date = date
  end
  def year; @date.year ;end
  def beginning_of_year; @date.beginning_of_year ;end
  def end_of_year; @date.end_of_year ;end
end


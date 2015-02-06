class Hospital::Meeting < ActiveRecord::Base
  extend CsvIo

  attr_writer :startday

  def startday   ; start.strftime("%d");end
  def day_column ; start.strftime("day%02d");end
  def day        ;start.day ;end
end

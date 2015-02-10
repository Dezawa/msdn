class Hospital::Meeting < ActiveRecord::Base
  extend CsvIo

  attr_writer :startday

    # t.integer  "busho_id"
    # t.date     "month"
    # t.integer  "number"
    # t.string   "name"
    # t.datetime "start"
    # t.float    "length",   limit: 24
    # t.boolean  "kaigi",  default: true

  def startday   #; logger.debug("### MEETING startday=#{startday}")
    start.strftime("%d");end
  def day_column ; start.strftime("day%02d");end
  def day        ; start.day ;end
end

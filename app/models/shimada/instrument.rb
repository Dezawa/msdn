class Shimada::Instrument < ActiveRecord::Base
  extend CsvIo
  has_many :shimada_dayly
end

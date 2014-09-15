class Ubr::Wall < ActiveRecord::Base
    extend CsvIo
    include Ubr::Const
    #self.table_name = "ubr_walls"
    belongs_to  :souko_floor,:class_name => "Ubr::SoukoFloor"
end

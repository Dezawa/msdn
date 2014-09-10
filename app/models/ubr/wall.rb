class Ubr::Wall < ActiveRecord::Base
    extend Function::CsvIo
    include Ubr::Const
    set_table_name :ubr_walls
    belongs_to  :souko_floor,:class_name => "Ubr::SoukoFloor"
end

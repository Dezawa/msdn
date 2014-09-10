# -*- coding: utf-8 -*-

module Ubr


  #
  # 全体
  #   右下方向が正
  #   単位は m。 例外：紙原点(左上)と印刷原点のずれ、SoukoPlan#offset は mm。
  #
  # 印刷位置
  #  アドレス原点は次の様に修飾される
  #   紙原点 
  #     -> SoukoPlan#offset                        : 印刷原点
  #         -> SoukoPlan#floor_offset              : 倉庫平面図の原点
  #              -> SoukoFloor#base_points         : 枠ブロックの基準点
  #                   -> Waku#pos_x,pos_y          : 枠先頭枡の右上の点：枠の並び方向に関わらず。
  #                   -> SoukoFloor#lael_pos       : 枠ブロックの名称



  class Pillar < ActiveRecord::Base
    extend CsvIo
    include Ubr::Const
    set_table_name :ubr_pillars
    belongs_to  :souko_floor,:class_name => "Ubr::SoukoFloor"

    def kazu ; [kazu_x,kazu_y]  ; end
    def start ; [start_x,start_y]  ; end
    def kankaku ; [kankaku_x,kankaku_y]  ; end
    def size ; [size_x,size_y]  ; end

    #attr_reader :size,:start,:kankaku,:missing,:size
    attr_reader :missing
    def ddinitialize(arg={ })
      [:size,:start,:kankaku,:missing,:size].each{| attr_name| 
        instance_variable_set  "@#{attr_name}",arg.delete(attr_name) 
      }
    end
  end
end

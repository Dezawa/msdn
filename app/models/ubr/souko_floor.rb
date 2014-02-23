# -*- coding: utf-8 -*-

module Ubr

  # name        : 単なる識別子。プログラムでしか使わない。  
  # outline     : 倉庫を囲う仮想の長方形。対角線の座標で指定 
  # walls       : 壁。
  # pillars     : Pillar の配列
  # 
  # contents    : 枠ブロックのprifix。ユニークである必要はない。
  #             : 同じprifixでも二種のsufixを持つことがあるので
  #             : 以下はcontentsの要素数と同じ数の定義が必要
  #   base_points : 原点に対する枠ブロック基準点の相対位置
  #   label_pos   : 枠ブロック名を出力する場所のbase_pointsに対する相対位置
  #               : nilの場合は出力しない
  #   sufix       : 枠ブロックの枠名の連番部分。ブロック先頭の枠名の物を指定。"A" とか "1" とか "01" とか
  #   max         : sufixの最後
  class SoukoFloor 
    Attrs =[:name,  :outline , :walls,:pillars ] #, :contents ,:sufix,:label_pos,:base_points,  :max]
    attr_reader *Attrs
    attr_reader :contents ,:sufix,:label_pos,:base_points,  :max
    def initialize(args={ })
      argss = { 
        :name=>"NON",  :outline => [],
        :walls => [],:pillars => []
        #:contents => [] ,:sufix => [],:label_pos => [], :base_points => [],  :max => 25 
      }.merge(args)
      Attrs.each{| attr_name|
        instance_variable_set  "@#{attr_name}",argss.delete(attr_name) 
      }
      blocks = Ubr::WakuBlock[@name]
      @contents   = blocks.map(&:content)
      @sufix      = blocks.map(&:sufix)
      @max        = blocks.map(&:max)
      @label_pos  = blocks.map(&:label_pos)
      @base_points= blocks.map(&:base_point)
    end
  end

end

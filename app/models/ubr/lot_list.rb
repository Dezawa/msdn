#!/usr/bin/ruby1.9
# -*- coding: utf-8 -*-
require 'pp'
#require 'my_csv'
require 'nkf'
module Ubr

#WithoutPull = true

#LotAttrs = [:grade,:meigara_code,:meigara,:lot_no,:count,
#            :packed_date,:hasuukubun,:unit,:dmy
#           ]
#SegAttrs = [:lot,:weight,:waku,:paret,:comment_urb,:comment_qa,:cause,:pull,:order,:direction]

#  Names = ("等級 品目コード 品目名称 ロット№ 個数 数量 単位 置場 ﾊﾟﾚｯﾄ 包装日 "+
#           "端数区分 物流注記 品質注記 降級原因 引当 受注№ 指図№").split
#  Attrs = [:grade,:meigara_code,:meigara,:lot_no,:count,:weight,:unit,:waku,:paret,
#           :packed_date,:hasuukubun,:comment_urb,:comment_qa,:cause,:pull,:order,:direction
#          ]
#Converter = [:str,:str,:str,:str,:int,:int,:str,:str,:str,:str,:str,:str]

#  Name2Attr = Hash[*Names.zip(Attrs).flatten]

class LotList
  include CsvIo
  delegate :logger, :to=>"ActiveRecord::Base"
  attr_writer :list , :list_by_id
  @@lotlist = nil
  def self.lotlist(reload=false,opt = { })
    return @@lotlist if @@lotlist && !reload
    @@lotlist = self.new
    @@lotlist.load(opt[:file] || Lot::SCMFILE)
    @@lotlist
  end 

  def initialize(arg={})
    @list=arg
  end

  def load(file,option = {:headers => :first_row})
    $WAKUMISSING = nil
    # UBRのexcelで来る № がうまくa変換できないので、その対策
    lines = NKF.nkf("-w",File.read(file))
    lines.gsub!(/"/,"")
    lines = lines.sub(/ロット[^,\t]*/,"ロット№").sub(/ﾊﾟﾚｯﾄ[^,\t]*/,"パレット").split(/[\n\r]+/)
#    logger.debug("Occupy:lines #{lines.first}")
    csvrows = lines.map{ |line| line.split(/[\t,]/)} #CSV.parse
    lbl2idx,indexes = serchLabelLine(csvrows,Names)
    
    columns = Attrs.dup
    csvrows.each{|row|      next unless row[1]
      attrs = Hash[*columns.zip(indexes.map{|idx| row[idx]}).flatten]

      create_lot(attrs)
    }
    if $WAKUMISSING
      logger.info("UBR:WakuMissing #{Time.now.strftime('%Y/%m/%d %H:%M')} #{$WAKUMISSING.sort.join(' ')}")
    end

    logger.debug("LotList.load: file #{file } line数#{lines.size } lot数#{self.size}")
    self
  end

  def create_lot(row)
    lot = Lot.create row
    return nil unless lot
    if @list[lot.id]
      @list[lot.id].add(lot.segments.first) #.weight,lot.waku.first)
    else
      @list[lot.id] = lot
    end
    @list[lot.id] 
  end
    
  def list(without_pull=WithPull,&block)
    unless without_pull
      return @list unless block
      list_wp = {}
      @list.each{|k,v|  list_wp[k]=v.dup }
    else
      #@list  id => lot
      list_wp = {}
      @list.each{|k,v|  list_wp[k]=v.dup }
      list_wp.each{|k,lot| lot.segments = lot.segments(WithoutPull)}.
      delete_if{|k,lot| lot.segments.size==0}
    end
    if block
      list_wp.each{|k,lot| lot.segments.delete_if{|segment| !yield(segment)}}.
      delete_if{|k,lot| lot.segments.size==0}
    end
    list_wp
  end
  
  def weight ;   @list.inject(0){|s,list| s + list[1].weight } ; end
  def paret_su ; @list.inject(0){|s,list| s + list[1].paret_su } ; end
  def masu_su  ; @list.inject(0){|s,list| s + list[1].need } ; end
  def names ;    @list.keys ;  end
  def size  ;    @list.size ; end
  def number_of_code ; @list.map{|id,lot| id[0]}.uniq.size ;end
  def number_of_lot  ; @list.values.inject(0){|s,lots| s+lots.size} ;end

  #############################
  # いろいろな　ID の一覧
  #############################
  def meigara_list; @list.keys.map{|meigara,lot,grade| meigara}.uniq;  end

  # 戻り値 : [ id,id,,,,]
  #             id = [code,lot_no]  
  def id_list_by_code_lotNo; @list.to_a.map{|id,lot| [id[0] ,id[1]]}.uniq;end


  #############################
  #  lot一覧付き
  #############################

  def select_segment(&block)
    @list.list{|id,lot| 
      
    }
  end
  
  def select(&block)
    @list.select(&block)
  end

  # 戻り値 : [ [id,[lot_list,lot_list,lot_list]],[  ],[  ]]
  #             id = [code,grade]  
  def group_by_code_grade(without_pull = false)
    group_by = @list.group_by{|id,lot| [id[0],id[2]] }
    unless without_pull
      group_by
    else
      group_by.each{|id,lot_ary| lot_ary.
        delete_if{|id,lot| lot.segments(WithoutPull).size == 0 }
      }
    end
  end

  # 指定銘柄のロット一覧
  # 戻り値 : [lot,lot,lot]
  def by_code(code) ; @list.values.select{|lot| lot.meigara_code == code } ;end

  #複数行の記載の有るロット
  # 　銘柄コードもロット番号も同じ物
  #       包装形態が違ってロット番号が同じ物もあるので
  #戻り値 [ [id,lot],[id,lot],,,]
  #          id = [code, lot_no,grade]
  def has_mult_segments
    @list.select{|id,lot| lot.segments.size>1 }
  end

  def has_mult_segments_for_same_waku(without_pull = WithPull)
    unless without_pull
      @list.select{|id,lot| 
        lot.segments.map{|seg| seg.waku}.uniq.size != lot.segments.size
      }
    else
      @list.select{|id,lot| 
        segs = lot.segments.select{|seg| seg.pull == ""}
        segs.map{|seg| seg.waku}.uniq.size != segs.size
      }
    end
  end

  #######################################################
  def extract_lot_list_by_niugoki( niugoki,opt )
    lot_list = if Meigara::NiugokiCode.include?  niugoki
                 list(opt[:without_pull]).values.
                   select{|lot| lot.send(opt[:classfy]) == niugoki}
               else
                 list(opt[:without_pull]).values
               end

    lot_list
  end
  def extract_lot_list_by_weight_class(classify,weight_class,opt )
#pp ["extract_lot_list_by_weight_class",classify,weight_class]
    lot_list = list(opt[:without_pull]).values.
      select{|lot| lot.send(classify) == weight_class }
    lot_list
  end


  # 1層分のtデータ、CSVでいえば XY一組分
  # block :: 横軸を決める式
  # option[:classfy] :: Y を選ぶ為の Log#method
  # classify ::
  def histgram(step_limit_unit_start,
               classify = :niugoki,niugoki = nil,block=nil,option = {} )
    opt = { 
      :method => nil, :without_pull => WithPull, :classfy => :niugoki
    }.merge(option)
    lot_list = case classify
               when :niugoki ;extract_lot_list_by_niugoki( niugoki,opt )
               when :weight_class,:ton10_class
                 extract_lot_list_by_weight_class(classify,niugoki,opt )
               else ;extract_lot_list_by_niugoki( niugoki,opt )
               end
    lot_list = lot_list.select{|lot| opt[:type] =~ lot.keitai } if opt[:type] 
    lot_list = lot_list.select{|lot| opt[:select].call(lot)}    if opt[:select] 
    hist_sub(lot_list,step_limit_unit_start,opt,block)
  end

  # option
  #  :method  :: 縦軸をなににするか
  #           ::   nil -> ロット数、 Lot#method
  #  :without_pull ::  ture -> 本日出荷の引き合いのある物は除く
  # block          :: 横軸を決める式
  # 
  # 
  def hist_sub(lot_list,step_limit_unit_start,opt,block)
#pp ["hist_sub",opt[:method]]
    upper = step_limit_unit_start[1]/step_limit_unit_start[0]
    v=Hash[*lot_list.group_by{|lot| block ?  block.call(lot) : nil
           }.map{|v,ary|
             if opt[:method]
               [v,ary.inject(0){|sum,lot| sum + lot.send(opt[:method])}]
              else 
                [v,ary.size]
              end
           }.flatten]
    start = (step_limit_unit_start[3] || 0)/step_limit_unit_start[0]
    vv=(start..upper-1).map{|i| [i*step_limit_unit_start[0],(v[i] || 0)]}
  end

  def histgram_place(niugoki = nil,option = {})
    opt = {:method => :weight, :without_pull => WithPull}
    opt.merge!(option)
    lot_list = extract_lot_list_by_niugoki( niugoki,opt )
    #lot_list = 
    #  case niugoki
    #  when nil
    #    @list.values
    #  else
    #    @list.values.select{|lot| #        puts lot.lot_no
    #    lot.meigara.niugoki == niugoki}
    #  end
    hist_palce_sub(lot_list,opt[:method])
  end

  def hist_palce_sub(lot_list,method)
    Hash.new{|h,k| h[k]=0}.merge(
      Hash[*lot_list.map{|lot| lot.segments}.flatten.
      group_by{|seg| seg.waku.location}.
           map{|v,ary| [v,ary.inject(0){|p,seg| p + seg.send(method)}]}.flatten]
                                 )
  end

  # ワンウェイ、１１型、14型の数を得る
  DIR="/home/dezawa/MSDN/Deverop/UbeChiba/資料/在庫/"
  CSVS=%w(SCM在庫一覧_20130304152517.csv コピーSCM在庫一覧_6月3日.csv SCM在庫一覧_20130829105531-1.csv SCM在庫一覧_2013_9月2日.csv)
  def stat
    lots=list.values
    st = { }
    lot_group_by_stack_limit = lots.group_by{ |lot| lot.stack_limit}
    #pp [lot_group_by_stack_limit.keys,lot_group_by_stack_limit.values.map{ |l| l.size}]
  end

  def self.stat
    llist=[]
    CSVS.each_with_index{ |csv,idx| 
      llist[idx] = self.lotlist(true,:file => DIR+csv)
    }
    llist.each{ |ll| ss=ll.stat
      lot_size = [1,2,3].map{ |i| ss[i].size}
      meigara_size = [1,2,3].map{ |i| ss[i].group_by{ |lot| lot.meigara_code}.uniq.size}
      pret_size    = 0#[1,2,3].map{ |i| ss[i].inject(0){ |s,lot| s+lot.paret_su}}
      weight       = [1,2,3].map{ |i| ss[i] ? ss[i].inject(0){ |s,lot| s+ lot.weight} : 0 }
      pp lot_size
      pp meigara_size
      pp pret_size   
      pp weight      
    }
  end
end
end
__END__
@Waku    = Ubr::Waku.waku(true) ;1
@lotlist = Ubr::LotList.lotlist(true);2
@lotlist.stat

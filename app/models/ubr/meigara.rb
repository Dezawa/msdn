#!/usr/bin/ruby1.9
# -*- coding: utf-8 -*-
require 'pp'
require 'csv'


  #品目コード	包装	パレット	積み
  #末尾	重量	重量	段数
module Ubr
class HousouKeitai
  delegate :logger, :to=>"ActiveRecord::Base"
  attr_reader :keitai,:unit_weight,:paret_weight,:stack_limit
   @@housoukeitai = nil
  def self.housou_keitai
    return @@housoukeitai if @@housoukeitai
    @@housoukeitai = {}
    # 包装  kg/包装 kg/パレット 段数
    [["00" , 8000 ,8000,1],
     ["A1" ,  400 , 400,2],
     ["A2" , 1000 ,1000,2],
     ["A3" , 3500 ,3500,2],
     ["A4" , 1100 ,1100,2],
     ["A5" ,10000 ,10000,2],
     ["F1" ,  400 , 400,2],
     ["F2" ,  500 , 500,2],
     ["F3" ,  550 , 550,2],
     ["F4" ,  800 , 800,2],
     ["F5" ,  900 , 900,3],
     ["F6" ,  950 , 950,3],
     ["F7" , 1000 ,1000,3],
     ["FM" ,  600 , 600,2], 
     ["FQ" ,  700 , 700,2],
     ["FT" ,  850 , 850,2],
     ["GD" ,  810 , 810,3],
     ["N1" ,   15 , 600,3],
     ["N2" ,   20 , 800,3],
     ["N3" ,   25 ,1000,3]
    ].each{|k,u,p,s| @@housoukeitai[k] = self.new(k,u,p,s) }
    @@housoukeitai
  end
  def initialize(arg_keitai,arg_unit_weight,arg_paret_weight,arg_stack_limit)
    @keitai      =  arg_keitai
    @unit_weight = arg_unit_weight
    @paret_weight= arg_paret_weight 
    @stack_limit = arg_stack_limit
  end
end

class Meigara
  delegate :logger, :to=>"ActiveRecord::Base"
  #品目コード 品目名称 		

  Attr_str = [:name,:code,:housou]
  Attr_num = [:ave_shipping,:niugoki]
  attr_accessor :name,:code,:shipping,:niugoki
  attr_reader   :housou
  # ２年間出荷量で荷動きの多寡を判定する                                     
  #Niugoki = [  1..420000, 420000..1200000,0..0, 1200000..2400000, 2400000..140000000 ]
  Niugoki = [  1..1000,1001..6499,6500..49224,0..0,49225..190999,191000..6617540]
  NiVLow,NiLow,NiMid,NiUnk,NiHigh,NiVHigh = 0,1,2,3,4,5
  NiugokiCode = [ NiVLow,NiLow,NiMid,NiUnk,NiHigh,NiVHigh ]

  @@meigara_by_code = nil
  @@meigara_by_name = nil

  def initialize(*args)
    arg = {}.merge(args.first)
    @name = arg.delete(:name)
    @code = arg.delete(:code)
    @shipping = arg.delete(:shipping).to_i
    @niugoki = arg.delete(:niugoki)|| niugoki_by_shipping(@shipping)
    @housou  = arg.delete(:housou)
    pp [@code,"Housou Missing"] unless @housou
    unless @housou 
      logger.info("UBR MEIGARA code '#{@code}' @name '#{@name}' 包装形態がない")
    end

  end

  def self.meigara_by_code ; 
    return @@meigara_by_code if  @@meigara_by_code
    load
    @@meigara_by_code
  end
  def self.meigara_by_name 
    unless @@meigara_by_name
      load
    end
    @@meigara_by_name 
  end

  def self.load #品目コード 品目名称 ２年売上
    @@meigara_by_code = {}
    @@meigara_by_name = {}

    #CSV.foreach(File.join($MasterDir,"Meigara.csv"),:headers => true) do |row|
    csv = open(File.join(Const::MasterDir,"Meigara.csv")) 
    csv.gets
    csv.each_line{ |line|
      row = CSV.parse_line(line)
    #CSV.parse(csv).each{ |row|
      next unless row[0] #&& row[1]
      @@meigara_by_code[row[0]] = @@meigara_by_name[row[1]] = 
        Meigara.new(:name => row[1],:code => row[0],
                    :housou => HousouKeitai.housou_keitai[row[0][-2..-1]],
                    :shipping => row[2].to_i
                    )
    }
  end

  def self.add_meigara(code,name)
        meigara= Meigara.new(:name => name,:code => code,
                             :housou => HousouKeitai.housou_keitai[code[-2..-1]]
                             )

    @@meigara_by_code[code] = @@meigara_by_name[name] =meigara
  end
    

  def niugoki_by_shipping(shipping)
    Niugoki.index{|ni| ni.include? shipping } || NiUnk
  end

  def inspect ; name ; end
  def to_s ; name ; end
  def unit_weight ; housou.unit_weight ;end
  def paret_weight ; housou.paret_weight ;end
  def stack_limit ; housou.stack_limit ;end
end
end

# -*- coding: utf-8 -*-
require 'csv'
require 'kconv'
module Ube::Function
module SkdCsv
  # self からcsvに吐き出す
  Head = %w(id jun 製品番号 数量 製品ID 製品名 銘柄 養生庫 東西 原新 抄造始 抄造終 養生始 養生終 乾燥始 乾燥終 加工始 加工終 抄造始 抄造終 養生始 養生終 乾燥始 乾燥終 加工始 加工終)
  Item1 = [:id,:jun,:lot_no,:mass,:ube_product_id,:proname,:meigara,:yojoko]
  Item3 = %w(plan_ result_).map{|pr| %w(shozo yojo dry kakou).map{|ope| %w(_from _to).map{|ft|
        (pr+ope+ft).to_sym
      }}}.flatten
  def csvout
    str=""
    csv = CSV::Writer.create(str) #,:headers => Head,:write_headers => true)
    csv << Head
    ube_plans.sort{|a,b|
        case [!!a.jun,!!b.jun]
        when [true,true] ; a.jun <=> b.jun
        when [true,false]; -1 
        when [false,true]; 1
        else ; 0 #a.id<=> b.id
        end
    }.each{|plan|
      items = Item1.map{|item| plan.send(item)}
      items.push(plan.shozo_w? ? "西" : "東")
      items.push(plan.dry_o?   ? "原" : "新" )
      csv << items + Item3.map{|item| plan.send(item) ? plan.send(item).strftime("%Y/%m/%d %H:%M"):""}
    }
    Kconv.tosjis(str)
  end
end
end

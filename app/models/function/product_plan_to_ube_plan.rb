# -*- coding: utf-8 -*-
require 'csv'
require 'jcode'

class Function::ProductPlanToUbePlan
  include Function::CsvIo
  include ExcelToCsv

  attr_reader :year_month,:l2i,:idxes,:last_row_no,:data_rows,:products,:errors
  attr_reader :csvfiles
  Idx = {
    :proname => 1,
    :date1   => 2
  }
  def initialize(file)
    @csvfiles = csv_files(file)
    init
  end
  def init
    io = open(@csvfiles.first)
    @year_month = set_year_month(io)
    @days_of_month = @year_month.end_of_month.day
    @rows       = CSV.parse io.read #.split("\n").map{|line| CSV.parse line}
    @errors = []
    month_label = (1..@days_of_month).map{|v| v.to_s}
    while(@l2i,@idxes   = serchLabelLine(@rows,month_label))[0].nil?;end
    
    #@last_row_no = searchLastRow
    #selectDataRows
    extructProduction # [1, "UB(東原)", 6.5]
  end

  def make_ube_plans
    jun = 3000
    plans = []
    @products.sort_by{|p| p[0]
    }.each{|pro|  plns=create_plan(pro); plans = plans + plns if plns 
    }
    plans.each{|plan| plan.jun = jun; jun += 10}
    plans
  end

  def create_plan(pro) # [1, "UB(東原)", 6.5]
    mass    = pro[2]*1000
    proname = pro[1].strip.tr_s("（）Ａ-Ｚａ-ｚ０-９","()A-ZA-Z0-9")
    product = UbeProduct.find_by_proname(pro[1])
    if product.nil?
      @errors << "製品 '#{pro[1]}'は製造条件一覧にありません"
      return nil
    end
    unless product.lot_size && product.lot_size > 1
      errors << msg="製品 '#{proname}'の基準製造量が未定義です 2304 としておきます。"
        logger.info msg
        product.lot_size =  2304 
    end
    # lotに分割する
    lotNr =  (mass.to_f/product.lot_size).ceil.to_f
    plns =lotNr.to_i.times.map{ 
      UbePlan.new(:ube_product_id =>product.id,:mass =>product.lot_size,:lot_no =>"") 
    } 
  end

  def set_year_month(io)
    line = io.gets
    line =~ /[ＨHh][\s,"]*(\d{1,2})[\s,"]+(\d{1,2})[\s,"]+月[\s,"]*度/
    Time.local(2012-24+$1.to_i,$2.to_i)
  end

  def selectDataRows
    @data_rows =
      @rows[0..@last_row_no].select{|row|  row[1] && row[1] !~ /^\d*$/ }
  end
  def searchLastRow
    @rows.each_with_index{|row,row_no| 
      return row_no-1 if row[0] && row[0] !~ /^([西東]抄造)?$/
    }
  end
  def extructProduction
    @products=[]
    @rows.each{|row|
      next unless row[1] && row[1] !~ /^\d*$/
      return if row[0] && row[0] !~ /^([西東]抄造)?$/
      proname=row[Idx[:proname]].to_s
      (1..@days_of_month).each{|date| 
        next if row[date+Idx[:date1]].to_f ==0
        sum = 0.0
        (0..31).each{|d| break if (val = row[d+date+Idx[:date1]].to_f)==0
          sum += val
          row[d+date+Idx[:date1]] = nil
        }
        @products << [date,proname,sum]
      }
    }
  end
end

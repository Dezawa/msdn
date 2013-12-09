# -*- coding: utf-8 -*-
# 作業指示書に明記する切り替えを登録する。
# UbeSkdHelp#change_time から参照される。
#   pre_condition_id :: 前品種のUbeOperation#id
#   post_condition_id:: 後品種のUbeOperation#id
#   ope_name         :: 東西抄造、原新乾燥、加工
#   display          :: 切り替えの製造番号　A??
#
class Ubeboard::NamedChange < ActiveRecord::Base
  extend CsvIo
  self.table_name = 'ubeboard_named_changes'

  belongs_to :pre_condition,:class_name => "Ubeboard::Operation",:foreign_key => :pre_condition_id
  belongs_to :post_condition,:class_name => "Ubeboard::Operation",:foreign_key => :post_condition_id

  # 前品種の品種名を返す
  def pre_con_name  ; pre_condition  ? pre_condition.ope_name  : nil ;end
  # 後品種の品種名を返す
  def post_con_name ; post_condition ? post_condition.ope_name : nil ;end

  # DBの登録内容を表形式で出力する。./script/console での実行が前提
  # UbeNamedChange.test
  def self.test
    ube_operations  = UbeOperation.find(:all).select{|ope| ope.ope_name !~ /^A/}
    @hinshu_names = ube_operations.map(&:ope_name)
    hinshu_ids    = ube_operations.map(&:id)
    @opes = %w(抄造 乾燥)

    sql = "ope_name = ? and ( pre_condition_id = ? and post_condition_id = ? or" +
      " pre_condition_id = ? and post_condition_id is null or "+
      " pre_condition_id is null and post_condition_id = ? )"
    @opes.each{|opename|
      puts "\n\n"+opename
      print ","+@hinshu_names.join(",")
      @hinshu_names.each_with_index{|hinshu,indx|  print "\n"+ hinshu+","
        pre_id = hinshu_ids[indx]
        hinshu_ids.each{|post_id| 
          both = UbeNamedChange.all(:conditions => [ sql,opename,pre_id,post_id,pre_id,post_id],
                                    :order => "jun").first
          disp = both ? both[:display] : ""
          print disp + ","
        }
      }    
    }

  end

  # UbeNamedChange.test2
  # Function::Ubeboad::boad::SkdHelp の named_change_pro_ids のテストを行う
  # と共に、UbeNamedChange database のデータの確認を行う。
   def self.test2(sep="\t",file=nil)
     #　抄造 乾燥　工程の、全 UbeOpeation#opename について調べる
     #  UbeNamedChange databaseはラインの違いは意識しない。
     @kind_names = UbeOperation.find(:all).map(&:ope_name).select{|n| n !~ /^A/}
     @real_opes = [:shozoe,:shozoe,:dryo,:drye].zip(%w(西抄造 東抄造 原乾燥 新乾燥))
     @skd       = UbeSkd.new
     hozen_names = Hash[*UbeProduct.find(:all,:conditions => "ope_condition like 'A%'").map{|op|
       [op.id,op.ope_condition]}.flatten]

    @real_opes.each{|real_ope,line_name|
      puts "#{line_name} "
      puts sep+@kind_names.join(sep)+"\n"
      @kind_names.each_with_index{|pre_kind,idx|
        print pre_kind + sep
        @kind_names.each_with_index{|post_kind,idx|
          ids = @skd.named_change_pro_ids(real_ope,pre_kind,post_kind)
           print ids.map{|id| hozen_names[id]}.join(" ")+sep
         }
         print "\n"
       }
         print "\n"
       }
   end

end

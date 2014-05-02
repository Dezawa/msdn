# -*- coding: utf-8 -*-
class Hospital::Limit < ActiveRecord::Base
  extend Function::CsvIo
  include Hospital::Const
  set_table_name 'hospital_limits'
  Code = [:code0,:code1,:code2,:code3,:coden]
  
  def after_find
    self.kinmu_total = 31 - code0 - coden unless kinmu_total# && kinmu_total>0
  end
  
  # 看護師  総数は足りるか [Kangosi,kinmu_total]
  # リーダー総数は足りるか [Leader ,night_total]
  # 日勤者数は足りるか     [Kangosi,Sshift1]
  # 夜勤者数は足りるか     [Kangosi,night_total]
  def self.enough?(busho_id,month=nil)
    $HP_DEF ||= Hospital::Define.create
    month ||= Time.local(2014,3,1) #標準的な休みの数な月

    arrowable = arrowable_roles(busho_id,month)
    needs     = need_roles(busho_id,month)
    margin    = margin_roles(needs,arrowable)

    insufficiency = margin.select{ |rs,mgn| mgn <  0 }
    fit           = margin.select{ |rs,mgn| mgn == 0 }
    less          = margin.select{ |rs,mgn| mgn >= 0 && mgn < MarginLimit[rs] }

    warning = [] 
    [[insufficiency,"%sには%sが延べ %d人日必要なところ、%d人日不足のため、計算不能です"],
     [less         ,"%sには%sが延べ %d人日必要なところ余裕は%d人日です。計算時間が掛かるかもしれません"]
    ].each{ |list,msg_fmt|
      list.each{ |rs,mgn| # {[role,sft_str] => mgn }
        role = rs[0]
        warning << msg_fmt % [ShiftName[rs[1]],Hospital::Role.id2name[rs[0]],needs[rs],mgn.abs]
      }
    }
    [warning,insufficiency,needs,margin]
  end
 
  def self.margin_roles(needs,allowable_roles)
    margin = Hash.new{ |h,k| h[k]=0}
    needs.keys.each{ |rs| margin[rs] = (allowable_roles[rs]||0) - needs[rs] if needs[rs]>0 }
    margin
  end

  def self.arrowable_roles(busho_id,month)
    # [role,shift] => 人数
    nurces = Hospital::Nurce.by_busho(busho_id)
    assinable = nurces.
      inject(Hash.new{ |h,k| h[k]=0}){ |sum,nurce|
      nurce.assinable_roles.to_a.each{ |rs,cnt|       sum[rs] += cnt}
      nurce.assinable_total.to_a.each{ |rs,cnt|       sum[rs] += cnt}
      sum
    }
  end

  def self.need_roles(busho_id,month)
    # {[role,shift] => count}
#pp Hospital::Need.needs_all_days(month,busho_id)[30]
    needs_all = 
      Hospital::Need.needs_all_days(month,busho_id)[1..month.end_of_month.day].
      inject(Hash.new{ |h,k| h[k]=0}){ |sum,need| need.each_pair{ |rs,minmax| sum[rs] += minmax[0]} 
      sum
    }
#pp needs_all
    # 看護師数、その他role必要数 { role => 延べ数 }
    nobe_suu = needs_all.to_a.inject(Hash.new{ |h,k| h[k]=0}){ |sum,rs_need|
      sum[[rs_need[0][0],:kinmu_total]] += rs_need[1] ;sum
    } 
    # 夜勤 必要role延べ数 { role => 延べ数 }。日勤は needs_all[role,shift]
    shift_role_nobe = needs_all.to_a.inject(Hash.new{ |h,k| h[k]=0}){ |sum,rs_need|
      sum[[rs_need[0][0],:night_total]] += rs_need[1] if $HP_DEF.night.include?(rs_need[0][1])
      sum
    } 
      
    needs = needs_all.merge(nobe_suu).merge(shift_role_nobe)
  end

end

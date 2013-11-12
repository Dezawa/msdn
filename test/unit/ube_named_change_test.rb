# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
class Function::UbeNamedChangeTest < ActiveSupport::TestCase
  fixtures :ube_products,:ube_operations,:ube_named_changes,:ube_plans,:ube_change_times

   def make_skd(ids=[])
    skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find
    skd.ube_plans=[]
    ids.each{|id| skd.ube_plans<< UbePlan.find(id) }
    skd
  end
  

  [ 
   [[43,41],[118],"S1コタタキ(東原)->12普3×6(東新)"],
   [[41,43],[118],"12普3×6(東新)->S1コタタキ(東原))"],
   [[40,43],[113],"12高級(東原)->S1コタタキ(東原))"],
   [[40,41],[113, 118],"12高級(東原)->12普3×6(東原))"],
   [[41,40],[118],"12普3×6(東原)->12高級(東原))"],
   nil
  ].each{|ids,ret,msg |
     next unless ids
     must "記名切り替え #{msg}" do
       skd=make_skd(ids)
       plan = skd.ube_plans[1]
       real_ope = plan.shozo?
       assert_equal ret,skd.named_change_pro_id(real_ope,skd.ube_plans[0].ope_condition_id,
                                                skd.ube_plans[1].ope_condition_id)
     end
   }

  [["抄造",7,"A10"],["抄造",13,"A12"],["乾燥",3,"A12"]
  ].each{|ope_name,post_condition_id,display|
    must "#{ope_name} ->#{post_condition_id} な記名切り替えは" do
      sql = "ope_name = ? and post_condition_id = ? and pre_condition_id is null "
      unc=UbeNamedChange.all(:conditions => [ sql,ope_name,post_condition_id])
      #pp [unc,ope_name,pre_condition_id]
      assert_equal display,
      unc.first[:display]
    end
  }

  [["抄造",7,"A10"],["抄造",2,"A09"],["乾燥",3,"A12"]
  ].each{|ope_name,pre_condition_id,display|
    must "#{ope_name} #{pre_condition_id}-> な記名切り替えは" do
      sql = "ope_name = ? and pre_condition_id = ? and post_condition_id is null "
      unc=UbeNamedChange.all(:conditions => [ sql,ope_name,pre_condition_id])
      #pp [unc,ope_name,pre_condition_id]
      assert_equal display,
      unc.first[:display]
    end
  }

  [["抄造",2,3,"A09 A12"],["抄造",2,13,"A12 A09"]
  ].each{|ope_name,pre_condition_id,post_condition_id,display|
    must "#{ope_name} #{pre_condition_id}->#{post_condition_id} な記名切り替えは" do
      sql = "ope_name = ? and pre_condition_id = ? and post_condition_id = ? "
      unc=UbeNamedChange.all(:conditions => [ sql,ope_name,pre_condition_id,post_condition_id])
      #pp [unc,ope_name,pre_condition_id]
      assert_equal display,
      unc.first[:display]
    end
  }


  must "総数は" do
    assert_equal 28,UbeNamedChange.count
  end

   NC_PLAN  = (75..82)
   NC_OPE   = [["抄造",:shozoe],["乾燥",:dryo],["乾燥",:dryn]]
   NC_REAL_OPE = [:shozoe,:dryo]
   #NC_PRO_ID = NC_PRO.map{|pro_name| UbeOperation.find_by_ope_name(pro_name).id}
   NC_RESULT =
     {
     :shozoe => {# 76 77 78    79    80    81 82
       74 => %w(000 114 000 118     118     118     000 122), #74 12普及化粧(東原)    
       75 => %w(114 000 114 114     114     114     114 114), #75 16高級(東原)        
       76 => %w(113 114 000 113,118 118,113 118,113 113 113), #76 12高級(東原)        
       77 => %w(118 114 118 000     000     000     118 118), #77 12普3×6化粧(東新)  
       78 => %w(118 114 118 000     000     000     118 118), #78 野地2M(東新)A12     
       79 => %w(118 114 118 000     000     000     118 118), #79 野地板(東新)        
       80 => %w(000 114 000 118     118     118     000 108), #80 S1コタタキ(東原)    
       81 => %w(122 114 122 118     118     118     107 000)  #81 型板                
     },
     :dryn   => {
       74 => %w(000 117  117 117),         #74 12普及化粧(東新)    
       77 => %w(117 000  000 000),         #77 12普3×6化粧(東新)  
       78 => %w(117 000  000 000),         #78 野地2M(東新)    
       79 => %w(117 000  000 000),         #79 野地板(東新)        
     },
     :dryo   => {
       75 => %w(000 000 107),         #75 16高級(東原)        
       76 => %w(000 000 107),         #76 12高級(東原)        
       80 => %w(108 108 000),         #80 S1コタタキ(東原)    
     }
   }
   NC_OPE.each{|ope,real_ope|# = NC_OPE[0]
     pre_plan_ids = NC_RESULT[real_ope].keys.sort
     pre_plan_ids.each{|pre_plan_id| pre_plan_ids.each_with_index{|post_plan_id,idx|
         must "#{ope}の記名切り替え #{pre_plan_id}->#{post_plan_id} の por_id は" do
           skd=make_skd([pre_plan_id,post_plan_id])
           pre_plan = skd.ube_plans[0]
           plan     = skd.ube_plans[1]
           assert_equal NC_RESULT[ real_ope][pre_plan_id][idx].sub(/000/,""),
           plan.change_time_concider_meigara(real_ope,pre_plan,skd).hozen_code_list.join(',')
         end
       }
     }
   }
end   
__END__

   NC_PLAN.each_with_index{|pre_plan_id,idx| NC_PLAN.each_with_index{|post_plan_id,jdx| 
       #NC_OPE.each_with_index{|ope,kdx|
       ope = "抄造"
       real_ope = :shozoe
         must "記名切り替え #{ope} plan #{pre_plan_id}->#{post_plan_id}" do
           skd=make_skd([pre_plan_id,post_plan_id])
           pre_plan = skd.ube_plans[0]
           plan     = skd.ube_plans[1]
#pp plan.change_time_concider_meigara(NC_REAL_OPE[kdx],pre_plan,skd)
           assert_equal NC_RESULT[real_ope][pre_plan_id][jdx].sub(/00/,""),
           #plan.named_change_pro_ids(NC_REAL_OPE[kdx],pre_plan).join(',')
           plan.change_time_concider_meigara(real_ope,pre_plan,skd).hozen_code_list.join(',')
         end
       }}

1	16高級		抄造	A10 	Edi   
1		16高級	抄造	A10 	Edi   
2	12高級	12普3×6	抄造	A09     	Edi    	削除
2	12高級	野地2M	抄造	A12 A09      	削除
2	12高級	野地板	抄造	A12 A09      	削除
2	15高級	12普3×6	抄造	A12     Edi    	削除
2	15高級	野地2M	抄造	A12 A09      	削除
2	15高級	野地板	抄造	A12 A09      	削除
3	12高級		抄造	A09 	Edi   
3	15高級		抄造	A09 	Edi   
4		12普3×6	抄造	A12  	削除
4		野地2M	抄造	A12 	Edi   
4		野地板	抄造	A12 	Edi   
4	12普3×6		抄造	A12  	削除
4	野地2M		抄造	A12 	Edi   
4	野地板		抄造	A12 	Edi   
4		12普3×6	乾燥	A12  	削除
4		野地2M	乾燥	A12 	Edi   
4		野地板	乾燥	A12 	Edi   
4	12普3×6		乾燥	A12  	削除
4	野地2M		乾燥	A12 	Edi   
4	野地板		乾燥	A12 	Edi   
5	S1コタタキ		乾燥	A05  	削除
5		S1コタタキ	乾燥	A04  	削除
5	S1コタタキ		抄造	A05  	削除
5		S1コタタキ	抄造	A04  	削除
6	型板		抄造	A14 	Edi   
6		型板	抄造	A14 	Edi   

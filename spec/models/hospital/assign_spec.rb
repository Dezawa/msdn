# -*- coding: utf-8 -*-
require 'spec_helper'
require 'testdata/hospital_assign_data'

def init
  mar=Date.new(2013,3,1)
  feb=Date.new(2013,2,1)
  @assign=Hospital::Assign.new(1,mar)
  @nurces=@assign.nurces
  @nurces.each_with_index{|nurce,idx|
    def nurce.shift_with_last_month
      Monthly2[id-34][-5..-1]+shifts
    end
    nurce.monthly(mar) #Monthly3
    nurce.set_shift_days(1, Monthly3[idx][1..-1])
  }

end

describe Hospital::Assign do
  before do
    init
  end
  it "初期化の確認 最初のnurceの shifts と shift_with_last_month は" do
    expect(@nurces.first.id).to eq 34
    expect(@nurces.first.shifts).to eq Monthly3.first
    expect(@nurces.first.shifts).to eq "______11_____________1______1___"
    expect(@nurces.first.shift_with_last_month).to eq "_1__1______11_____________1______1___"
  end

  it "nurceの3/1のrole_shift" do
    expect(@nurces.map{|nurce| nurce.role_shift(@month)[1] }).
      to eq [[[1, "_"], [2, "_"]],                                              #1          34
             [[1, "1"], [2, "1"], [4, "1"]],   [[1, "1"], [2, "1"], [5, "1"]],  #2,3,4,5
             [[2, "1"], [4, "1"]],             [[1, "1"], [2, "1"], [4, "1"]],
             [[1, "2"], [2, "2"], [4, "2"]],   [[1, "2"], [2, "2"], [4, "2"]],  # 6,7
             [[1, "3"], [2, "3"], [4, "3"]],                                    # 8         41
             [[2, "_"], [4, "_"], [5, "_"]],   [[2, "_"], [4, "_"], [5, "_"]],  # 42,43  44,45  46,47,48, 
             [[2, "_"], [4, "_"], [5, "_"]],   [[2, "_"], [4, "_"], [5, "_"]],
             [[2, "_"], [5, "_"]],             [[1, "_"], [2, "_"], [5, "_"]], [[1, "_"], [2, "_"], [5, "_"]], 
             [[1, "_"], [2, "_"], [5, "_"]],   [[1, "_"], [2, "_"], [5, "_"]], [[2, "_"], [5, "_"]],
             [[2, "_"], [5, "_"]]]
  end
 
  count_role_shift_of = {[1, "_"]=>5, [2, "_"]=>12 , [4, "_"]=>4 , [5, "_"]=>11 ,
             [1, "1"]=>3, [2, "1"]=>4  , [4, "1"]=>3 ,[5, "1"]=>1,
             [1, "2"]=>2, [2, "2"]=>2  , [4, "2"]=>2 ,
             [1, "3"]=>1, [2, "3"]=>1  , [4, "3"]=>1
    }


  it "3/1のcount_role_shift" do
    expect(@assign. count_role_shift(true)[1]).to eq count_role_shift_of
  end

  it "3/1のcount_role_shift_of" do
    expect(@assign. count_role_shift_of(1,true)).to eq count_role_shift_of
  end

  needs_all_days = { # [2,"0"]は休暇のために Hospital::Needとは別に作り出される
    [2,"0"]=>[0,6], [2,"1"]=>[9,11], [3,"1"]=>[0,1], [4,"1"]=>[1,2],[5,"1"]=>[1,2],
    [1,"2"]=>[1,1], [2,"2"]=>[2,2] , [3,"2"]=>[0,1], [4,"2"]=>[1,2],[5,"2"]=>[1,2],
    [1,"3"]=>[1,1], [2,"3"]=>[2,2] , [3,"3"]=>[0,1], [4,"3"]=>[1,2],[5,"3"]=>[1,2],
  }
  it "3/1のneeds_all_days" do
    expect(@assign.needs_all_days(true)[1]).to eq needs_all_days
  end

  #count_role_shift = {[1,"1"]=>3, [2,"1"]=>4, [4,"1"]=>3, [5,"1"]=>1,
  #                     [1,"2"]=>2, [2,"2"]=>2, [4,"2"]=>2, 
  #                     [1,"3"]=>1, [2,"3"]=>1, [4,"3"]=>1
  #                   }
  #it "count_role_shift_of" do
  #  expect(@assign.count_role_shift_of(1)).to eq count_role_shift
  #end

  Short_role_shift =
  [[13, # shift 1 に 1人
    {   [1, "3"]=>[1, 1], [2, "3"]=>[2, 2], [3, "3"]=>[0, 1], [4, "3"]=>[1, 2], [5, "3"]=>[1, 2],
        [1, "2"]=>[1, 1], [2, "2"]=>[2, 2], [3, "2"]=>[0, 1], [4, "2"]=>[1, 2], [5, "2"]=>[1, 2],
        [2, "0"]=>[0, 6], [2, "1"]=>[8, 10],[3, "1"]=>[0, 1], [4, "1"]=>[0, 1], [5, "1"]=>[1, 2]}   ],
   [ 1, # 金曜、1が４、2が２、3が1割り当てられている
     { [1, "3"]=>[0, 0], [2, "3"]=>[1, 1], [3, "3"]=>[0, 1], [4, "3"]=>[0, 1], [5, "3"]=>[1, 2],
       [1, "2"]=>[0, 0], [2, "2"]=>[0, 0], [3, "2"]=>[0, 1], [4, "2"]=>[0, 0], [5, "2"]=>[1, 2],
       [2, "0"]=>[0, 6], [2, "1"]=>[5, 7], [3, "1"]=>[0, 1], [4, "1"]=>[0, 0], [5, "1"]=>[0, 1]}   ],
   [ 4, # 月曜、一つも割り付けられていない
     { [1, "3"]=>[1, 1], [2, "3"]=>[2, 2], [3, "3"]=>[0, 1], [4, "3"]=>[1, 2], [5, "3"]=>[1, 2],
       [1, "2"]=>[1, 1], [2, "2"]=>[2, 2], [3, "2"]=>[0, 1], [4, "2"]=>[1, 2], [5, "2"]=>[1, 2],
       [2, "0"]=>[0, 6], [2, "1"]=>[9, 11],[3, "1"]=>[0, 1], [4, "1"]=>[1, 2], [5, "1"]=>[1, 2]}]
  ]

  Short_role_shift3_1_after = 
    {
    [1, "3"]=>[0, 0], [2, "3"]=>[0, 0], [3, "3"]=>[0, 1], [4, "3"]=>[0, 1], [5, "3"]=>[0, 1],
    [1, "2"]=>[0, 0], [2, "2"]=>[0, 0], [3, "2"]=>[0, 1], [4, "2"]=>[0, 0], [5, "2"]=>[1, 2],
    [2, "0"]=>[0, 6], [2, "1"]=>[5, 7], [3, "1"]=>[0, 1], [4, "1"]=>[0, 0], [5, "1"]=>[0, 1]} 
  

Short_role_shift.each{|day,short_role_shift_of_day|
    it "3/#{day}の看護師必要数" do
      expect(@assign.short_role_shift_of(day,true)).to eq short_role_shift_of_day
     end
   }

  it "3/1にNurce46を3に割り当てる" do
    expect(@assign.short_role_shift_of(1,true)).to eq Short_role_shift[1][1]
    @assign.short_role_shift_of(1,true)
    @nurces[46-34].set_shift(1,"3")
    expect(@assign.short_role_shift_of(1,true)).to eq Short_role_shift3_1_after
  end
  it "Assignからの割り当てでは再計算不要" do
      expect(@assign.short_role_shift_of(1,true)).to eq Short_role_shift[1][1]
    @assign.short_role_shift_of(1,true)       # patern   dayly_check
    @assign.assign_patern(@nurces[46-34,1],1,3,   [ ["3",[[],[],[],[]]] ]      )
    expect(@assign.short_role_shift_of(1)).to eq Short_role_shift3_1_after
  end

    it "3/1のこのshiftの看護師の必要数と不足role " do
    expect(@assign.short_role(1,"3",true)).to eq [2,5]
    expect(@assign.short_role(1,"2",true)).to eq [5]
    expect(@assign.short_role(1,"1",true)).to eq [2]
  end

  it "role_order_by_tightnessは" do
    expect(@assign.role_order_by_tightness("1")).to eq [1,4,5,2]
    expect(@assign.role_order_by_tightness("2")).to eq [1,4,5,2]
    expect(@assign.role_order_by_tightness("3")).to eq [1,4,5,2]

  end

  it "tight_roles は" do
    expect(@assign.tight_roles("1")).to eq [1,4,5]
    expect(@assign.tight_roles("2")).to eq [1,4,5]
    expect(@assign.tight_roles("3")).to eq [1,4,5]
  end

  it "shift2,3の看護師のcost" do
    @assign.night_mode =  true
    tightness = @assign.tight_roles("3")
    expect(@nurces.map{|nurce| nurce.cost("2",tightness)}).
      to eq [644, 857, 779, 338, 496, 595, 595, 496, 410, 410, 410, 410, 308, 451, 451, 451, 451, 308, 308]
    expect(@nurces.map{|nurce| nurce.cost("3",tightness)}).
      to eq [644, 857, 779, 338, 496, 496, 496, 595, 410, 410, 410, 410, 308, 451, 451, 451, 451, 308, 308]
  end #     12    124  125  24  124  124  124  124  245  245  245  245  25  125  125  125  125  25  25
      #     34    35   36   37  38   39   40    41   42   43   44   45   46  47  48   49   50   51   52  53
      # 12  34
      # 24  37*
      # 25  46,51,52
      # 124 38*,39*,40* 41* 35*
      # 125 47,48,49,50 36
      # 245 42,43,44,45

  it "3/1 shift3 assinable_nurces " do
    @assign.night_mode =  true
    expect(@assign.shifts_night[true]).to eq %w(2 3)
    day,sft_str,short_roles = 1,"3",{"2"=>[5], "3"=>[2,5]} #[2,5]
    assinable_nurces = @assign.assinable_nurces(day,sft_str,short_roles[sft_str])
    expect(assinable_nurces.map(&:id)).to eq [34, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52]
    tightness = @assign.tight_roles("3")
    expect(assinable_nurces.map{|nurce| nurce.cost("3",tightness ) } ).
      to eq [644, 410, 410, 410, 410, 308, 451, 451, 451, 451, 308, 308]
  end #     [34,  42,  43,  44,  45,  46,  47,  48,  49,  50, 51, 52]
  #     [34, 52, 46, 51, 44, 43]

  it "3/1のneed_nurces_roles。" do
    @assign.night_mode =  true
    expect(@assign.shifts_night[true]).to eq %w(2 3)
    need_nurces_roles = @assign. selected_nurces_need_nurces_short_roles_of_(1)
    expect(need_nurces_roles[2]).to eq Hash[{"2"=>[5], "3"=>[2, 5]}] #不足role
    expect(need_nurces_roles[1]).to eq Hash[{"2"=>0, "3"=>1}] #不足人数
    expect(need_nurces_roles[0]["2"]).to eq [] # shift 2 の候補なし
    # 3/1 可能なのは 34,42-52。（不足が25だから）34はrole[2] 以外は[25]としてgroupingされる
    expect(need_nurces_roles[0]["3"].map(&:id)).to eq [51, 52, 46, 44, 43, 34] # shift 2 の候補なし
  end  #                           51,52,46,37,42-45  [51, 52, 46, 44, 43, 34]


  it "3/1 assinable_nurces_by_cost_size_limited " do
    @assign.night_mode =  true
    expect(@assign.shifts_night[true]).to eq %w(2 3)
    #  need_nurces[sft_str] = short_role_shift_of_day[[2,sft_str]][0]
    #  short_roles[sft_str] = short_role(day,sft_str)
    day,sft_str,short_roles ,need_nurces = 1,"3",{"2"=>[5], "3"=>[2,5]},Hash[{"2"=>0,"3"=>1}]
    expect(@assign.
           assinable_nurces_by_cost_size_limited(@assign.assinable_nurces(day,sft_str,short_roles[sft_str]),
                                                         sft_str, need_nurces, short_roles).
           map(&:id)).
      to eq [51, 52, 46, 44, 43, 34]
  end

  it "3/1での割り当て候補" do
    @assign.night_mode =  true

    selected_nurces_need_nurces_short_roles_of_ = @assign.selected_nurces_need_nurces_short_roles_of_(1)
    expect(selected_nurces_need_nurces_short_roles_of_[1]).to eq Hash[{"2"=>0, "3"=>1}]
    expect(selected_nurces_need_nurces_short_roles_of_[2]).to eq Hash[{"2"=>[5],"3"=>[2,5]}]
    expect(selected_nurces_need_nurces_short_roles_of_[0]["2"]).to eq []
    expect(selected_nurces_need_nurces_short_roles_of_[0]["3"].map(&:id)). 
      to eq [51, 52, 46, 44, 43, 34]

  end

  it "3/1でのshift3の候補組み合わせ" do
    @assign.night_mode =  true
    day = 1
    ready_for_day_reentrant = @assign.ready_for_day_reentrant(day)
    expect(ready_for_day_reentrant[0]["2"].map{|c| c.map(&:id)}).to  eq []
    expect(ready_for_day_reentrant[0]["3"].map{|c| c.map(&:id)}).
      to eq [[51], [52], [46], [44], [43]]
  end


  # 3/1での group_by
  #[[[1, 2], [34]],
  # [[1, 2, 4], [38,39,40, 41, 35]],
  # [[1, 2, 5], [47,48,49,50, 36]],
  # [[2, 4], [37]],
  # [[2, 4, 5], [42,43,44,45]],
  # [[2, 5], [46, 51, 52]]]


  it "3/4での割り当て候補" do
    @assign.night_mode =  true
    selected_nurces_need_nurces_short_roles_of_ = @assign.selected_nurces_need_nurces_short_roles_of_(4)
    expect(selected_nurces_need_nurces_short_roles_of_[1]).to eq Hash[{"2"=>2, "3"=>2}]
    expect(selected_nurces_need_nurces_short_roles_of_[2]).to eq Hash[{"2"=>[1,2,4,5],"3"=>[1,2,4,5]}]
    expect(selected_nurces_need_nurces_short_roles_of_[0]["2"].map(&:id)).
      to eq [46, 37, 42, 50, 41, 34]
           # 34 38-40 47-50 37 42-45 46
    expect(selected_nurces_need_nurces_short_roles_of_[0]["3"].map(&:id)). 
      to eq [46, 37, 42, 50, 47, 39, 38, 34]
    tightness = @assign.tight_roles("3")
  end

  it "3/4でのshift3の候補組み合わせ" do
    @assign.night_mode =  true
    day = 4
    tightness = @assign.tight_roles("3")
    selected_nurces_need_nurces_short_roles_of_ = @assign.selected_nurces_need_nurces_short_roles_of_(4)
    nurce_combination_by_tightness = 
      @assign.nurce_combination_by_tightness(selected_nurces_need_nurces_short_roles_of_[0]["3"],
                                       2,[1,2,4,5],"3")
    ready_for_day_reentrant = @assign.ready_for_day_reentrant(day)
    #expect(ready_for_day_reentrant).to eq [1]
    expect(ready_for_day_reentrant[0]["3"].map{|ns| ns.map(&:id)}).
      to  eq [ [37, 47], [37, 50], [46, 39], [46, 38], [42, 50], [42, 47], [42, 38], [42, 39],
               [47, 38], [50, 39], [47, 39], [50, 38], [42, 34]]
  end # [[37, 47], [37, 50], [46, 38], [46, 39], [42, 50], [42, 47], [42, 34], [42, 38], [42, 39], [50, 39], [50, 38], [47, 38], [47, 39]]

end



__END__

save_shift(nurces,day)

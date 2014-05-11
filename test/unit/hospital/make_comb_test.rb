# -*- coding: utf-8 -*-
require 'test_helper'
#require 'need'
require 'test/unit/hospital/make_comb_testdata'

class Hospital::AssignCombinationTest < ActiveSupport::TestCase
  include Hospital::Const
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits,:hospital_defines
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes
  # Replace this with your real tests.
  def setup
    update
    @month  = Date.new(2013,3,1)
    @busho_id =  3
    @assign = Hospital::Assign.new(@busho_id,@month)
    @nurces = @assign.nurces
    @assign.night_mode = true
  end


  def nurce_set(ids)
    ids.map{ |id| Hospital::Nurce.find id}
  end

  def extract_set_shifts(string)
    nurces=[]
    string.each_line{|line|
      hp,assign,id,data,dmy = line.split(nil,5)
      case id
      when /^\d+$/
        nurces[id.to_i]=@assign.nurce_by_id(id.to_i)
        @assign.nurce_set_patern(nurces[id.to_i],1,data[1..-1].chop)
      when  /ENTRY/
      end
    }
    #@assign.refresh
    #nurces.compact
  end

  def id_dump_of(ary_of_combination)
    "[" + ary_of_combination.map{ |comb| comb.map(&:id).join(",")}.join("],[")+"]"
  end
  
  def id_map_of(ary_of_combination)
    ary_of_combination.map{ |comb| comb.map(&:id)}
  end
   
  def id_map_of_ary_of_combination_of_combination(ary_of_combination)
    ary_of_combination.map{ |combs| combs.map{ |comb| comb.map(&:id)}}
  end
  
   
  def nurce_by_id(id,nurces)
    nurces.select{ |n| n.id == id}[0]
  end

  must "update" do
    assert_equal [4, 6],Hospital::Nurce.find(1).hospital_roles.map(&:id)
  end

 Expects = 
    { 1 => 
    { "3" => [
            [3,9,10],    #tight_role
            [5,6,7,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], #assinable_nurces
            [[15, 20, 22, 18, 19, 21, 23, 16, 17],   #  4 10    gather_by_each_group_of_role
             [29, 30, 9],                            #  49
             [26, 25, 27, 28, 24],                   #  4910
             [11, 13, 12],                           # 34 10
             [6, 7, 8, 5],                           # 349
             [10]                                    # 34910
            ],    
            [15, 9, 27, 13, 8, 10, 23, 30, 26, 11, 5, 21, 29, 25], #   assinable_nurces_by_cost_size_limited
              [5,5,4,5,5,5,5,5,5], # remain          ],
              %w(1024.0 1023.2 1330.1 1023.9 1023.7 1023.1 1023.8 1023.8 1023.9)  #cost
             ],
      "2" => [
            [3,9,10],    #tight_role
            [5,6,7,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], #assinable_nurces

            [[20, 19, 21, 18, 22, 23, 15, 16, 17],   #  4 10    #gather_by_each_group_of_role
             [29, 9, 30],                            #  49
             [26, 24, 28, 27, 25],                   #  4910
             [12, 13, 11],                           # 34 10
             [7, 8, 5, 6],                           # 349
             [10]                                   # 34910  8324.37115197942]
            ],    
            [16, 29, 25, 13, 8, 10, 20, 30, 28, 11, 7, 18, 9, 26] , #   assinable_nurces_by_cost_size_limited
              [5,5,4,5,5,5,5,5,5], # remain          ],
              %w(1023.3 1023.5 1330.9 1023.4 1023.9 1023.6 1023.0 1023.9 1023.7) #cost

             ]

    },
    2 => 
    { "3" => [
            [3,9,10],    #tight_role
            [5,6,7,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], #assinable_nurces
            [ [15, 16, 23,   18, 22, 20, 21, 19, 17],   #  4 10    gather_by_each_group_of_role
              [ 9, 29, 30],                             #  49
              [24, 25, 26,   27, 28],                   #  4910
              [11, 12,      13],                        # 34 10
              [ 5,  6,       7,   8],                   # 349
              [10]                                      # 34910
            ],    
            [15, 9, 24, 11, 5, 10, 16, 29, 25, 12, 6, 23, 30, 26], #   assinable_nurces_by_cost_size_limited
              [3,3,4,5,5,5,5,5,3], # remain          ],
              [1730, 1730, 1330, 1023, 1023, 1023, 1023, 1023, 1730]  #cost
             ],
   "2" => [
            [3,9,10],    #tight_role
            [5,6,7,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], #assinable_nurces
            [[15, 20, 22, 18, 19, 21, 23, 16, 17],  #  4 10    gather_by_each_group_of_role 
             [29, 30, 9],                            #  49
             [26, 25, 27, 28, 24],                   #  4910
             [11, 13, 12],                           # 34 10
             [6, 7, 8, 5],                           # 349
             [10]                                    # 34910
            ],    
            [15, 9, 24, 11, 5, 10, 16, 29, 25, 12, 6, 23, 30, 26] , #   assinable_nurces_by_cost_size_limited
              [5,3,4,5,5,5,5,5,3], # remain          ],
              [1023, 1730, 1330, 1023, 1023, 1023, 1023, 1023, 1730]  #cost

          ]
    }
  }
  

  ["2","3"].each{ | sft_str|

    must "3/1の#{sft_str}のtight_role" do
      day = 1
      extract_set_shifts(Log3[1])
      assert_equal Expects[day][sft_str][0],@assign.tight_roles(sft_str)
    end

    must "3/1の shift #{sft_str},id [15, 16, 23, 18, 22, 20, 21, 19, 17] のshift残がおかしい" do
    day = 1
    extract_set_shifts(Log3[1])
    remain = [15, 16, 17, 18, 19, 20, 21, 22, 23].map{ |id|
      @assign.nurce_by_id(id).shift_remain(true)[sft_str]
    }
    assert_equal  Expects[day][sft_str][4],remain
    end

    must "3/1の shift #{sft_str},id [15, 16, 23, 18, 22, 20, 21, 19, 17] のコストがおかしい" do
    day = 1
    extract_set_shifts(Log3[1])
    cost = [15, 16, 17, 18, 19, 20, 21, 22, 23].map{ |id|
      "%.1f"%@assign.nurce_by_id(id).cost(sft_str,@assign.tight_roles(sft_str)) 
    }
    assert_equal Expects[day][sft_str][5],cost
    end
    
    must "3/1の#{sft_str}の可能看護師" do
      day = 1
      extract_set_shifts(Log3[1])
      assert_equal  Expects[day][sft_str][1],
      @assign.assinable_nurces(day,sft_str, @assign.short_role(day,sft_str)).map(&:id)
    end

    must "3/1の#{sft_str}のgather_by_each_group_of_role可能看護師" do
      day = 1
      extract_set_shifts(Log3[1])
      assert_equal Expects[day][sft_str][2],
      @assign.gather_by_each_group_of_role( @assign.assinable_nurces(day,sft_str, @assign.short_role(day,sft_str)),
                                          sft_str, @assign.short_role(day,sft_str)).map{ |ns| ns.map(&:id)}
    end

    must "3/1の#{sft_str}の選ばれし可能看護師" do
      day = 1
      extract_set_shifts(Log3[1])
      assert_equal Expects[day][sft_str][3],
      @assign.assinable_nurces_by_cost_size_limited(sft_str, day,@assign.short_role(day,sft_str)
                                                    ).map(&:id)
    end
  }

  must "3/1のshift2,3の組み合わせの組み合わせ" do
    day = 1
    combinations,need_nurces,short_roles = @assign.ready_for_day_reentrant(day)
    comb_of_comb =     combinations["2"][0,20].product(combinations["3"][0,20]).sort_by{ |comb2,comb3| 
      @assign.cost_of_nurce_combination_of_combination(comb2,comb3)
    }[0,20]
    assert_equal [
 [[[18, 19, 30, 13], [29, 11, 22]], "8324.3"],
 [[[11, 19, 30, 16], [21, 11, 30]], "8325.3"],
 [[[18, 19, 13, 9], [21, 29, 11]],  "8325.1"],
 [[[29, 11, 19, 16], [21, 12, 9]],  "8324.5"],
 [[[18, 11, 19, 30], [21, 11, 9]],  "8324.5"],
 [[[18, 29, 19, 13], [11, 30, 22]], "8324.5"],
 [[[18, 19, 30, 13], [29, 16, 12]], "8325.0"],
 [[[18, 30, 13, 16], [21, 11, 9]],  "8325.5"],
 [[[18, 29, 11, 19], [11, 16, 9]],  "8324.6"],
 [[[18, 29, 11, 16], [21, 12, 9]],  "8324.7"],
 [[[19, 30, 13, 16], [21, 11, 9]],  "8323.3"],
 [[[29, 11, 19, 16], [11, 16, 30]], "8325.9"],
 [[[18, 30, 13, 16], [30, 12, 22]], "8325.0"],
 [[[18, 29, 19, 13], [21, 11, 9]],  "8324.2"],
 [[[18, 11, 16, 9] , [21, 29, 11]], "8324.8"],
 [[[19, 30, 13, 16], [11, 22, 9]],  "8323.9"],
 [[[18, 13, 16, 9] , [21, 29, 11]], "8324.4"],
 [[[11, 19, 16, 9] , [11, 30, 22]], "8325.2"],
 [[[18, 11, 19, 30] , [21, 12, 9]], "8324.8"],
 [[[29, 11, 19, 16], [21, 11, 9]],  "8324.4"]] ,
    id_map_of_ary_of_combination_of_combination(comb_of_comb).
      zip(comb_of_comb.map{ |combs| "%.1f"%@assign.cost_of_nurce_combination_of_combination(*combs)} )
  end
end
__END__


  ["2","3"].each{ | sft_str|
    must "3/3の#{sft_str}のtight_role" do
      day = 3
      extract_set_shifts(Log3[3]
      assert_equal Expects[day][sft_str][0],@assign.tight_roles(sft_str)
    end
    
    must "3/3の#{sft_str}の可能看護師" do
      day = 3
      extract_set_shifts(Log3[3])
      assert_equal  Expects[day][sft_str][1],
      @assign.assinable_nurces(day,sft_str, @assign.short_role(day,sft_str)).map(&:id)
    end

    must "3/3の#{sft_str}のgather_by_each_group_of_role可能看護師" do
      day = 3
      extract_set_shifts(Log3[3])
      assert_equal Expects[day][sft_str][2],
      @assign.gather_by_each_group_of_role( @assign.assinable_nurces(day,sft_str, @assign.short_role(day,sft_str)),
                                          sft_str, @assign.short_role(day,sft_str)).map{ |ns| ns.map(&:id)}
    end

    must "3/3の#{sft_str}の選ばれし可能看護師" do
      day = 3
      extract_set_shifts(Log3[3])
      assert_equal Expects[day][sft_str][3],
      @assign.assinable_nurces_by_cost_size_limited(sft_str, day,@assign.short_role(day,sft_str)
                                                    ).map(&:id)
    end

    must "3/3の shift #{sft_str},id [15, 16, 23, 18, 22, 20, 21, 19, 17] のコストがおかしい" do
    day = 3
    extract_set_shifts(Log3[3])
    cost = [15, 16, 17, 18, 19, 20, 21, 22, 23].map{ |id|
      @assign.nurce_by_id(id).cost(sft_str,@assign.tight_roles(sft_str)) 
    }
    assert_equal Expects[day][sft_str][5],cost
    End

    must "3/3の shift #{sft_str},id [15, 16, 23, 18, 22, 20, 21, 19, 17] のshift残がおかしい" do
    day = 3
    extract_set_shifts(Log3[3])
    remain = [15, 16, 17, 18, 19, 20, 21, 22, 23].map{ |id|
      @assign.nurce_by_id(id).shift_remain(true)[sft_str]
    }
    assert_equal  Expects[day][sft_str][4],remain
    end

  }
end
 

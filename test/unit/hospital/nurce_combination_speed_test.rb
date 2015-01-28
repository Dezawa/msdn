# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::NurceCombinationSpeedTest < ActiveSupport::TestCase
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes,:hospital_defines
  # Replace this with your real tests.

  Log2_4 = 
"
  HP ASSIGN 34 _220330_______________________
  HP ASSIGN 35 _220330______________________ 4 9
  HP ASSIGN 36 _220330______________________ 4 10
  HP ASSIGN 37 _____________________________ 4 9
  HP ASSIGN 38 _2___________________________ 3 4 9
  HP ASSIGN 39 _3___________________________ 3 4 9
  HP ASSIGN 40 _22__________________________ 3 4 9
  HP ASSIGN 41 ___33________________________ 3 4 9
  HP ASSIGN 42 _____2203____________________ 4 9 10
  HP ASSIGN 43 _____2203____________________ 4 9 10
  HP ASSIGN 44 _____3302____________________ 4 9 10
  HP ASSIGN 45 _22033_______________________ 4 9 10
  HP ASSIGN 46 _22033022____________________ 4   10
  HP ASSIGN 47 _22033022____________________ 3 4   10
  HP ASSIGN 48 _2203303303__________________ 3 4   10
  HP ASSIGN 49 _2203302203__________________ 3 4   10
  HP ASSIGN 50 _220330220330________________ 4 10
  HP ASSIGN 51 _220330220330________________ 4 10
  HP ASSIGN 52 __300____0_0___________0_____ 4 10
"
  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign = Hospital::Assign.new(@busho_id,@month)
    @nurces = extract_set_shifts(Log2_4)
    srand(1)
    @assign.refresh
  end

  def nurce_by_id(id,nurces)
    nurces.select{ |n| n.id == id}[0]
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
    nurces.compact
  end

  day = 20

  must "2/20のshift2,3の割り当て可能看護師 数制限" do
    assinable_nurces_for_shift23 =
      %w(2 3).map{ |sft_str| 
      @assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                    @assign.short_role(day,sft_str))
    }
    assert_equal [[37, 39, 46, 42, 51, 41, 43, 49], [37, 46, 42, 38, 49, 43, 39, 47]],
    ids_of_ary_of_ary(assinable_nurces_for_shift23)
  end

  count = 1
  must "2/20のshift2,3の割り当て組み合わせby Product" do
    combinations23 =
      %w(2 3).map{ |sft_str| 
      @assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                    @assign.short_role(day,sft_str)).
      combination(4).to_a
    }
    # 4C8 = 8 7 6 5/(4 3 2) = 70
    assert_equal [70,70],combinations23.map{ |c| c.to_a.size},"Combination size"
    assert_equal 4900 , combinations23[0].product(combinations23[1]).to_a.size,"Product size"
    # 8
    

    start = Time.now
    (1..count).each{ 
      combinations23 =
      %w(2 3).map{ |sft_str| 
        @assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                    @assign.short_role(day,sft_str)).
        combination(4).to_a
      }
      combs = combinations23[0].product(combinations23[1]).
      select{ |comb2,comb3|
        (comb2 + comb3).size == (comb2 | comb3).size
      }.sort_by{ |comb2,comb3|  @assign.cost_of_nurce_combination_of_combination(comb2,comb3) }
#      puts combs.size
    }
    puts "#{(Time.now - start)} sec by Procust " # 48.888896 sec by Procust /100
    assert (2.9..3.0).include?(Time.now - start) # 0.5 sec/round
  end


  must "2/20のshift2,3の割り当て組み合わせ not by Product" do

    start = Time.now
    (1..count).each{ 
      assinable_nurces23  =
      %w(2 3).map{ |sft_str| 
        @assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                      @assign.short_role(day,sft_str))
      }

      combinations23 = []
      assinable_nurces23[0].combination(4).
      each{ |comb2|
        rest3 = assinable_nurces23[1] - comb2
        rest3.combination(4).
        each{ |comb3| combinations23 << [comb2,comb3]}
      }
      combinations23.
      sort_by{ |comb2,comb3|  @assign.cost_of_nurce_combination_of_combination(comb2,comb3) }
    }
      puts "#{(Time.now - start)} sec not by Procust " # 31.839125 sec not by Procust/100
      assert (2.9..3.0).include?(Time.now - start) # 0.3 sec/round
  end
end

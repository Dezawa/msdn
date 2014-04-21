# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::KinmucodeTest < ActiveSupport::TestCase
    fixtures :hospital_kinmucodes,:hospital_roles

  Kubun=  { }
  def setup
  Hash[:nikkin,"日勤",:sankoutai,"三交代",:part,"パート",:touseki,"透析",
                   :l_kin,"L勤",:gairai,"外来",:kyoutuu,"共通"].
    each_pair{ |kinmu,name|  Hospital::Kinmucode::Kubun[kinmu] = (k=Hospital::Role.find_by_name(name)) ? k.id : nil }
  end

  must "勤務コード数" do
    assert_equal 82,Hospital::Kinmucode.count
  end

  (1..80).each{|id|
    next if [56,57,58,62,63,64].include? id
    must "勤務コードID #{id}の時間総計は 1.0" do
      kc = Hospital::Kinmucode.find(id)
#puts kc["am"]
      assert_equal 1.0,
      %w(nenkyuu am pm night midnight am2 pm2 night2 midnight2).
        inject(0.0){|sum,item| sum + kc[item]}
    end
  }
#
  [[1,"4□ 0 N D 1 2 3 1 Z G 管  G S A"],[2,""]].each{|kinmu,reslt|
    must "日勤の希望時 選択肢は" do
      assert_equal "0 N D 4□ 管 1 2 3 S A 会□ 会１  Z□ G R1□ Z/R□ R/G□ J1 出 出/1□ 1/出 出/G Z/出",
      Hospital::Kinmucode.code_for_hope(1).map{|c,i| c}.join(" ")
    end
  }
  #must "三交代の希望時 選択肢は" do
  #  assert_equal "0 N D 1 2 3 S A L2 L3 会 会1 □ △ ▲ Z G R1 Z/R R/G R2 R3 H1 H2 H3 イ１ イ２ イ３ 1/セ 出 出/1 1/出 出/G Z/出",
  #  Hospital::Kinmucode.code_for_hope(2).map{|c,i| c}.join(" ")
  #end

  must "id2kinmutype" do
    #assert_equal [0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] , Hospital::Kinmucode.id2kinmutype(1)
    #assert_equal [0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] , Hospital::Kinmucode.id2kinmutype(1001)
    #assert_equal [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] , Hospital::Kinmucode.id2kinmutype(67)
  end
  #1 2 3 l2 l5 会 会1 4□ 0  遅 外 N
  [         1,2,3,4,5,6,7,16,17,18  ,30 ,67,68,70,71].
    zip( %w(1 2 3 2 3 1 1 5  6  4   1   0 1 1 0)). #[1,2,3,2,3,1,1,1,0,nil,nil,0]).
    each{|id,ret|
    must "#{id}の0123は" do
      assert_equal ret,Hospital::Kinmucode.find(id).to_0123
    end
  }
  kinmukubun_id=2
   %w(0 1 2 3 4 5 6 7 8 9 A B C F).
    zip([[67,71,72,73,74,75,76,77,78,79,80], #0
         [1,6,7,8,9,10],[2,4],[3,5],         #123
         [13,18,21,25],[16,19,22],[17,20,23],#456
         [15,24,27],[14,26],[11],[12],[],[],[] #789AB
        ]).
  each{|shift,ret| next unless shift
    must "" do
      assert_equal ret,Hospital::Kinmucode.from_0123[kinmukubun_id][shift],
      "#{kinmukubun_id} #{shift}"
    end
  } 
 kinmukubun_id=1
   %w(0 1 2 3 4 5 6 7 8 9 A B C F).
    zip([[67,71,72,73,74,75,76,77,78,79,80],  #0
         [30,31,32,34],[2,4],[3,5],           #123
         [13,18,21,25],[16,19,22],[17,20,23], #456
         [15,24,27],[14,26],[11],[12],[]      #789AB
        ]).
  each{|shift,ret| next unless shift
    must "" do
      assert_equal ret,Hospital::Kinmucode.from_0123(shift,kinmukubun_id)
      "#{kinmukubun_id} #{shift}"
    end
  }
shifts = %w(0 1 2 3 5 L M N O)
Id = {       #  0   1 2 3  5 L M N  O
 :nikkin    => [67,30,2,3,33,4,5,81,82],
 :sankoutai => [67, 1,2,3,16,4,5,81,82]
}

 shifts.each_with_index{ |shift,idx| 
    kinmukubun = :nikkin; kinmukubun_id = Hospital::Kinmucode::Kubun[kinmukubun]
    msg = "#{kinmukubun}=#{ kinmukubun_id}:#{shift}の勤務コード"
    must msg do
      kinmukubun_id = Hospital::Kinmucode::Kubun[kinmukubun]
      assert_equal  Id[kinmukubun][idx],Hospital::Kinmucode.from_0123(shift,kinmukubun_id),
      msg
    end
    }
 shifts.each_with_index{ |shift,idx| 
    kinmukubun0 = :sankoutai; kinmukubun_id0 = Hospital::Kinmucode::Kubun[kinmukubun0]
    msg = "#{kinmukubun0}=#{ kinmukubun_id}:#{shift}の勤務コード"
    must msg do
      kinmukubun_id0 = Hospital::Kinmucode::Kubun[kinmukubun0]
      assert_equal  Id[kinmukubun0][idx],Hospital::Kinmucode.from_0123(shift.to_s,kinmukubun_id0),
      msg
    end
    }
    
end

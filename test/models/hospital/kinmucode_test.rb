# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::KinmucodeTest < ActiveSupport::TestCase
    fixtures "hospital/kinmucodes","hospital/roles"

  def setup
  end

  must "勤務コード数" do
    assert_equal 72,Hospital::Kinmucode.count
  end

  must "定数 sanchoku" do
    assert_equal 2,Hospital::Kinmucode.sanchoku
  end

  (1..80).each{|id|
    next if [51,52,56,57,58,61,62,63,64,65,66].include? id
    must "勤務コードID #{id}の時間総計は 1.0" do
      kc = Hospital::Kinmucode.find(id)
#puts kc["am"]
      assert_equal 1.0,
      %w(nenkyuu am pm night midnight am2 pm2 night2 midnight2).
        inject(0.0){|sum,item| sum + kc[item]}
    end
  }

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
shifts = %w(0 1 2 3 5 L M)
Id = {       #  0   1 2 3  5 L M 
 :nikkin    => [67,30,2,3,33,4,5],
 :sankoutai => [67, 1,2,3,16,4,5]
}

 shifts.each_with_index{ |shift,idx| 
    kinmukubun = :nikkin; kinmukubun_id = Hospital::Kinmucode::Kubun[kinmukubun]
    msg = "#{kinmukubun}=#{ kinmukubun_id}:shift=#{shift}の勤務コード"
    must msg do
      kinmukubun_id = Hospital::Kinmucode::Kubun[kinmukubun]
      assert_equal  Id[kinmukubun][idx],Hospital::Kinmucode.from_0123(shift,kinmukubun_id),
      msg
    end
    }
 shifts.each_with_index{ |shift,idx| 
    kinmukubun0 = :sankoutai; kinmukubun_id0 = Hospital::Kinmucode::Kubun[kinmukubun0]
    msg = "#{kinmukubun0}=#{ kinmukubun_id0}:#{shift}の勤務コード"
    must msg do
      kinmukubun_id0 = Hospital::Kinmucode::Kubun[kinmukubun0]
      assert_equal  Id[kinmukubun0][idx],Hospital::Kinmucode.from_0123(shift.to_s,kinmukubun_id0),
      msg
    end
    }
    
end
# -*- coding: utf-8 -*-

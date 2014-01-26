# -*- coding: utf-8 -*-
require 'spec_helper'

describe "20人職場の、roleが[2,5]の人のコスト" do
  describe "shift初期値なにもなし" do
    before do
      @nurce = Hospital::Nurce.find(46)
      @nurce.monthly(Date.new(2013,3,1))
    end
    #                
    [[[1,5,2],410], # c1,c2 Cost4 133
     [[1,2,5],410], # c2,c1     4 1
     [[5,1,2],451], # c0,c2     5
     [[5,2,1],496], # c0,c1     6
     [[2,1,5],451], # c0,c2     5
     [[2,5,1],496]  # c0,c1     6
    ].each{|tightness,cost|
      it "tightness = #{tightness}の時のコストは" do
        # まだ割付ていないから、@nurce.assinable_roles は{[2, "0"]=>8,[2, "1"]=>20, [2, "2"]=>5, [2, "3"]=>5}
        # ので、shift_remain は  {"0"=>8.0, "1"=>20, "2"=>5, "3"=>5}
        ### tightness は 部署全体による値
        expect(@nurce.role_ids).to eq [2,5]
        expect(@nurce.cost("2",tightness)).to eq cost # tightness の上下2roleなのでCost[5]、残り5

      end
    }
  end

  describe "shift残数2" do
    before do
      @nurce = Hospital::Nurce.find(46)
      @nurce.monthly(Date.new(2013,3,1))
      @nurce.shifts[3,3]="222"
    end
    [[[1,5,2],708], # c1,c2 Cost4 133
     [[1,2,5],708], # c2,c1     4 1
     [[5,1,2],779], # c0,c2     5
     [[5,2,1],857], # c0,c1     6
     [[2,1,5],779], # c0,c2     5
     [[2,5,1],857]  # c0,c1     6
    ].each{|tightness,cost|
      it "tightness = #{tightness}の時のコストは"  do
        # まだ割付ていないから、@nurce.assinable_roles は{[2, "0"]=>8,[2, "1"]=>20, [2, "2"]=>5, [2, "3"]=>5}
        # ので、shift_remain は  {"0"=>8.0, "1"=>20, "2"=>5, "3"=>5}
        ### tightness は 部署全体による値
        expect(@nurce.role_ids).to eq [2,5]
        expect(@nurce.cost("2",tightness)).to eq cost # tightness の上下2roleなのでCost[5]、残り5
      
    end
    }
  end
end
describe "20人職場の、roleが[1,2,5]の人のコスト" do
  describe "shift初期値なにもなし" do
    before do
      @nurce = Hospital::Nurce.find(47)
      @nurce.monthly(Date.new(2013,2,1))
      @nurce.shifts="_"*32
    end
    #                
    [[[1,5,2],545], # c0,c1,c2 Cost7 133
     [[1,2,5],545], # c2,c1     4 1
     [[5,1,2],545], # c0,c2     5
     [[5,2,1],545], # c0,c1     6
     [[2,1,5],545], # c0,c2     5
     [[2,5,1],545]  # c0,c1     6
    ].each{|tightness,cost|
      it "tightness = #{tightness}の時のコストは" do
        # まだ割付ていないから、@nurce.assinable_roles は{[2, "0"]=>8,[2, "1"]=>20, [2, "2"]=>5, [2, "3"]=>5}
        # ので、shift_remain は  {"0"=>8.0, "1"=>20, "2"=>5, "3"=>5}
        ### tightness は 部署全体による値
        expect(@nurce.cost("2",tightness)).to eq cost
      end
    }
  end
end
__END__
nurceのコスト計算

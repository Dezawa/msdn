# -*- coding: utf-8 -*-
require 'spec_helper'

TEST_DATA =
  { 
  42 => {
    need_role_ids: [2,4,5],
    roles:    [[2, "看護師"], [4, "Aチーム"], [5, "Bチーム"]],
    role_id:  [false,true,false,true,true],
    limit_id: 42,
    reguration: 4,
    busho_name: "本館東3階西",
    initial_shift: "________________________________",
    shift_with_last_month:  "0___________________________________",
    want_days:  [],
    want:         [],
    assign_check:   [1,false],
    set_shift:         [5,"3"],
    from_to0:        [31,30],
    set_shift_days:  [11,"321"],
    from_to1:       [30,27],
    clear:           "________________________________",
    assignable:  {[2, "0"]=>8, [4, "0"]=>8, [5, "0"]=>8, 
      [2, "1"]=>20, [4, "1"]=>20, [5, "1"]=>20,
      [2, "2"]=>5, [4, "2"]=>5, [5, "2"]=>5,
      [2, "3"]=>5, [4, "3"]=>5, [5, "3"]=>5},
    used: {[2, "0"]=>0, [4, "0"]=>0, [5, "0"]=>0, 
      [2, "1"]=>0, [4, "1"]=>0, [5, "1"]=>0,
      [2, "2"]=>0, [4, "2"]=>0, [5, "2"]=>0,
      [2, "3"]=>0, [4, "3"]=>0, [5, "3"]=>0},
    remain: {[2, "0"]=>8, [4, "0"]=>8, [5, "0"]=>8, 
      [2, "1"]=>20, [4, "1"]=>20, [5, "1"]=>20,
      [2, "2"]=>5, [4, "2"]=>5, [5, "2"]=>5,
      [2, "3"]=>5, [4, "3"]=>5, [5, "3"]=>5},
    shift_remain: {"0"=>8.0, "1"=>20.0, "2"=>5, "3"=>5},
    shift_remain2: {"0"=>7.0, "1"=>19.0, "2"=>4, "3"=>4},
    used2: {[2, "0"]=>1, [4, "0"]=>1, [5, "0"]=>1, 
      [2, "1"]=>1, [4, "1"]=>1, [5, "1"]=>1,
      [2, "2"]=>1, [4, "2"]=>1, [5, "2"]=>1,
      [2, "3"]=>1, [4, "3"]=>1, [5, "3"]=>1},
    remain2: {[2, "0"]=>7, [4, "0"]=>7, [5, "0"]=>7, 
      [2, "1"]=>19, [4, "1"]=>19, [5, "1"]=>19,
      [2, "2"]=>4, [4, "2"]=>4, [5, "2"]=>4,
      [2, "3"]=>4, [4, "3"]=>4, [5, "3"]=>4},
    shift:  "________________________________",
    shift2: "_______________1230_____________"
  },
  
  1 => {
    need_role_ids: [2],
    roles:    [[2, "看護師"]],
    role_id:  [false,true,false,false,false],
    limit_id: 1,
    reguration: 4,
    busho_name: "本館東5階",
    initial_shift: "__231___1_1_____________________",
    shift_with_last_month:  "__011_231___1_1_____________________",
    want_days:  [1,2,3,4],
    want:         [nil,1,2,0],
    assign_check:   [1,false],
    set_shift:         [5,"3"],
    from_to0:        [26,25],
    set_shift_days:  [11,"321"],
    from_to1:       [25,22],
    clear:           "__23____1_1_____________________",
    assignable:  {[2, "0"]=>8,[2, "1"]=>20, [2, "2"]=>2, [2, "3"]=>2},
    used: {[2, "0"]=>0, [2, "1"]=>3, [2, "2"]=>1, [2, "3"]=>1},
    remain: {[2, "0"]=>8,[2, "1"]=>17, [2, "2"]=>1, [2, "3"]=>1},
    shift_remain: {"0"=>8.0, "1"=>17.0, "2"=>1, "3"=>1},
    used2:   {[2, "0"] => 1, [2, "1"] => 4, [2, "2"] => 2, [2, "3"] => 2},
    remain2:  {[2, "0"] => 7, [2, "1"] => 16, [2, "2"] => 0, [2, "3"] => 0},
    shift_remain2: {"0"=>7.0, "1"=>16.0, "2"=>0, "3"=>0},
    shift:  "__231___1_1_____________________",
    shift2: "__231___1_1____1230_____________"
  }
}

This_month = Time.now.beginning_of_month.to_date
Next_month = Time.now.beginning_of_month.next_month.to_date

describe "ID=!,2013/3のデータで" do
  before do
    @nurce = Hospital::Nurce.find(1)
    @nurce.monthly(Date.new(2013,3,1))
  end

  it "月度集計は" do
    expect([:shift1,:shift2,:shift3].map{|sht| @nurce.send sht}).to eq [3.0,1.0,1.0]
  end
end


TEST_DATA.each{|id,td|
  describe "ID=#{id}の看護師を読み込むと" do
    before do
      @nurce = Hospital::Nurce.find(id)
    end
    
    it "ID=#{id} が持つロールのID" do
      expect(@nurce.need_role_ids).to eq td[:role_ids]
    end

    it "ID=#{id} が持つロール" do
      expect(@nurce.roles).to eq td[:roles]
    end
    
    it "ID=#{id}が持つロール一覧" do
      #      expect(%w(看護師 準看護師 リーダー Aチーム Bチーム).map{|role|
      #       @nurce.role?(role)
      #           }).to eq [true,false,false,false,false]
      expect( [1,2,3,4,5].map{|role_id|
                @nurce.role_id?(role_id)
              }).to eq td[:role_id]
    end
    it "ID=#{id} Limitが付く" do
      expect(@nurce.limit.id).to be td[:limit_id]
    end
    
    it "ID=#{id} after_find が動く" do
      expect(@nurce.Reguration).to have(td[:reguration]).items
    end
    it "ID=#{id} 部署名は" do
      expect(@nurce.busho.name).to eq td[:busho_name]
    end
    it "ID=#{id} defaultの月度は来月" do
      expect(@nurce.monthly.month).to eq Next_month
    end
    it "ID=#{id} その後無指定なら同じ月度" do
      expect(@nurce.monthly(nil).month).to eq Next_month
    end
    it "ID=#{id} その後今月指定なら" do
      expect(@nurce.monthly(This_month).month).to eq This_month
      expect(@nurce.monthly(nil).month).to eq This_month
    end
  end

  describe "ID=#{id} 割付の扱い" do
    before do
      @nurce = Hospital::Nurce.find(id)
      @nurce.monthly(Date.new(2013,3,1))
    end
    it "ID=#{id} 割付の初期値" do #          1234...8.0
      expect(@nurce.shifts).to eq td[:initial_shift]
    end
    it "ID=#{id} 前月末からの初期値" do
      expect(@nurce.shift_with_last_month).to eq td[:shift_with_last_month]
    end

    it "ID=#{id} 希望か？ " do
      expect(td[:want_days].map{|day| @nurce.monthly.days[day].want}).
        to eq td[:want]
    end

    it "ID=#{id} 割り付けられているか調べる" do
      expect(@nurce.assigned?(td[:assign_check].first)).to eq td[:assign_check][1]
    end
    it "ID=#{id} 割付られて居ない日の数" do
      expect(@nurce.shifts).to eq td[:initial_shift]

      expect{ @nurce.set_shift(*td[:set_shift]) }.
        to change{ @nurce.days_not_assigned }.from(td[:from_to0][0]).to(td[:from_to0][1])
      expect{ @nurce.set_shift_days(*td[:set_shift_days]) }.
        to change{ @nurce.days_not_assigned}.
        from(td[:from_to1][0]).to(td[:from_to1][1])
      
    end
    it "ID=#{id} 割付クリアすると、wantが1,2以外が_になる"  do
      @nurce.clear_assign
      expect(@nurce.shifts).to eq td[:clear]
    end

    it "ID=#{id} 割付可能ロール" do
      expect(@nurce.assinable_roles).to eq td[:assignable]
    end

    it "ID=#{id} 割り付け済みロール,残りロール" do
      #   "__231___1_1_____________________"
      used ={[2, "0"]=>0, [2, "1"]=>3, [2, "2"]=>1, [2, "3"]=>1}
      remain ={[2, "0"]=>8,[2, "1"]=>17, [2, "2"]=>1, [2, "3"]=>1}
      
      expect(@nurce.role_used).to eq td[:used]
      expect(@nurce.role_remain).to eq td[:remain]
      expect(@nurce.shift_remain).to eq td[:shift_remain]
      #expect(@nurce.role_shift).to eq []
    end

    it "ID=#{id} 割付したときに、割付済み、残り は変わる" do
      #      234...8.0
      #   "__231___1_1_____________________"                              

      expect(@nurce.role_used).to eq td[:used]
      expect(@nurce.role_remain).to eq td[:remain]
      expect(@nurce.shift_remain).to eq td[:shift_remain]
      expect(@nurce.shifts).to eq td[:shift]
      @nurce.set_shift_days(15,"1230")

      expect(@nurce.shifts).to eq td[:shift2]
      expect(@nurce.role_used).to eq td[:used2]
      expect(@nurce.role_remain).to eq td[:remain2]
      expect(@nurce.shift_remain).to eq td[:shift_remain2]      
    end
    
  end
}

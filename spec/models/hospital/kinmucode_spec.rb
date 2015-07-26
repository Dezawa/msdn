# -*- coding: utf-8 -*-
require 'spec_helper'

# 
def clear
  [ :nenkyuu,:am,:pm,:night,:midnight, :am2,:pm2,:night2,:midnight2].each{|time|
    @kinmucode[time] = nil
  }
end

 
describe Hospital::Kinmucode do
  array = (1..80).to_a.
    zip(%w(1 2 3 2 3 1 1 1 1 1
           9 A 4 8 7 5 6 4 5 6 
           4 5 6 4 4 8 7 C B 1
           1 1 5 1 9 A 4 8 7 4
           4 8 7 C B 1 1 1 1 1
           1 1 1 2 3 F F F 4 4
           1 F F F 4 4 0 1 1 1
           0 0 0 0 0 0 0 0 0 0
         )
       )
  describe "shift の正当性" do
    array.each{|kinmucode_id,shift|
      it "kinmucode ID= #{kinmucode_id}のshiftは" do
        @kinmucode = Hospital::Kinmucode.find(kinmucode_id)
        expect(@kinmucode.to_0123).to eq shift
      end
    }
  end

  describe "午前～午後の勤務係数の正当性 " do
    before do
      @kinmucode = Hospital::Kinmucode.find(1)
    end
    it "初期値は" do
      expect([@kinmucode.nenkyuu,@kinmucode.am,@kinmucode.pm,@kinmucode.night,
             @kinmucode.midnight,
             @kinmucode.am2,@kinmucode.pm2,@kinmucode.night2,@kinmucode.midnight2]).
        to eq [0.0, 0.5, 0.5, 0.0, 0.0,0.0, 0.0, 0.0, 0.0]
    end


    it "休みが0,0.5,1.0でないとエラー" do
      clear
      @kinmucode.nenkyuu = 0.7
      expect(@kinmucode.valid?).to be_false
      expect(@kinmucode.errors.values.flatten).to include("ID=1:休みが0,0.5,1.0でない")
    end

    [nil,0.0,0.5,1.0].each{|day|
      it "休みが #{day}はOK" do
        clear
        @kinmucode.nenkyuu = day
        @kinmucode.valid?
        expect(@kinmucode.errors.values.flatten).to_not include("ID=1:休みが0,0.5,1.0でない")
      end
    }

    [:am,:am2].each{|am|
      it "#{am}を1はNG" do
        clear
        @kinmucode[am]=1
        expect(@kinmucode.valid?).to eq  false
        expect(@kinmucode.errors.values.flatten).to include("ID=1:AM勤が0,0.5でない")
      end

      it "#{am}を0.5はOK" do
        clear
        @kinmucode[am]=0.5
        @kinmucode.valid?
        expect(@kinmucode.errors.values.flatten).to_not include("ID=1:AM勤が0,0.5でない")
      end
    }


    [:night,:midnight,:night2,:midnight2].each{|sft|
      it "#{sft}を0.5はNG" do
        clear 
        @kinmucode[sft] = 0.5
        expect(@kinmucode.valid?).to be_false
        expect(@kinmucode.errors.values.flatten).to include("ID=1:夜勤が0.0,1.0でない")
      end
    }

    [{nenkyuu: 1.0},{am: 0.5,pm: 0.5},{am: 0.5,pm2: 0.5},{night: 1.0},{midnight2: 1.0},
     {nenkyuu: 0.5, am: 0.5},{nenkyuu: 0.5, pm2: 0.5}].
      each{|arg|
      it "#{arg}はOK" do
        clear
        arg.each{|time,value| @kinmucode[time]=value }
        expect(@kinmucode.valid?).to be_true
      end
    }

    [{nenkyuu: 1.0, am: 0.5},{am: 0.5,night: 1.0},{am: 0.5,pm2: 0.5,nenkyuu: 0.5},
     {night: 1.0,nenkyuu: 0.5}].
      each{|arg|
      it "#{arg}はNG" do
        clear
        arg.each{|time,value| @kinmucode[time]=value }
        expect(@kinmucode.valid?).to be_false
        expect(@kinmucode.errors.values.flatten).to include("ID=1:一日の合計が1でない")        
      end
    }
  end

end
__END__
    it "nenkyuuを1に" do
      clear
      @kinmucode.nenkyuu=1;
      expect(@kinmucode.valid?).to eq  false
      expect(@kinmucode.errors.values.flatten).to eq ["ID=1:一日の合計が1でない"]
    end

    [:night,:midnight,:night2,:midnight2].each{|sft|
      it "#{sft}を1に" do
        @kinmucode.am=@kinmucode.pm=0
        @kinmucode[sft] = 1.0
        expect(@kinmucode.valid?).to be_true

      end
    }

  end
end


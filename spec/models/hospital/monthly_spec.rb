# -*- coding: utf-8 -*-
require 'spec_helper'

describe Hospital::Monthly do

  describe "ID=1の月度情報を読み込むとafter_find が動いて" do
    before do
      @monthly = Hospital::Monthly.find(1)
    end
     
    it "daysに展開" do
      expect(@monthly.days).to have(32).items
    end
    it "shiftに展開" do
      expect(@monthly.shift).to eq "__231___1_1_____________________"
    end

    it "02日は1002" do
      expect(@monthly.day02).to eq 1002
    end
    it "02日は1002だから、days[2]のcodeは2" do
      expect(@monthly.days[2].shift).to eq "2"
    end
  end
end

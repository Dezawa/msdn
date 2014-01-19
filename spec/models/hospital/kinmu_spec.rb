# -*- coding: utf-8 -*-
require 'spec_helper'
describe Hospital::Kinmu do
  want=0
  kinmu=30
  shift = "1"
  describe "希望#{want} 勤務#{kinmu}の" do
    before do
      @kinmu = Hospital::Kinmu.create(want*100+kinmu)
    end
    it "kinmucode_idは#{kinmu}" do
      expect(@kinmu.kinmucode_id).to eq kinmu
    end

    it "希望は#{want}" do
      expect(@kinmu.want).to eq want
    end
      
    it "shiftは#{shift}" do
      expect(@kinmu.shift).to eq shift
    end
  end
end

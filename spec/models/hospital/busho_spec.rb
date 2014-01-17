# -*- coding: utf-8 -*-
require 'spec_helper'


describe Hospital::Busho do
 fixtures "hospital/bushos"
 describe "部署数:" do
    it "not null" do
      expect(Hospital::Busho.count).to have(4).items
    end
  end
end

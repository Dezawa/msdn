# -*- coding: utf-8 -*-
require 'spec_helper'

describe Hospital::Role do
  it "ロール一覧" do
    expect(Hospital::Role.roles).to eq [[1, "リーダー"], [2, "看護師"], [3, "準看護師"], [4, "Aチーム"], [5, "Bチーム"]]
  end
end

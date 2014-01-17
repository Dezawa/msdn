# -*- coding: utf-8 -*-
require 'spec_helper'  
require 'features_helper'  

describe "dezawaのとき"   do
    fixtures :users,:user_options
    fixtures :user_options_users

  before do
    login
  end
  
  %w(線形計画法 複式簿記 宇部病院LiPS 生産計画 生産計画一覧
     ユーザメンテ オプションメンテ 勤務割付 倉庫管理 パスワード変更 ログアウト).
    each{|label|
    specify label+"へのリンクがある" do
      expect(page).to have_link label
    end
  } 
  specify "MSDNトップへはりんくがない" do
    expect(page).to have_no_link "MSDN Top"
  end

  User.all.each{|user|
    user.user_options.select{|option| option.order > 0 }.each{|option|
      label = option.label
      specify "ユーザ#{user.username}のメニューは"+label+"へのリンクがある" do
        expect(page).to have_link label
      end
    }
  }
end


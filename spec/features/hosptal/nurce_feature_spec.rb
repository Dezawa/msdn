# -*- coding: utf-8 -*-
require 'spec_helper'
require 'features_helper'
require 'pp'

describe Hospital::NurcesController,"一覧画面" do
  fixtures :users,:user_options,:user_options_users
  fixtures "hospital/nurces","hospital/bushos","hospital/limits"
  fixtures "hospital/roles","hospital/nurces_roles"

  
  login = "dezawa"
  result= :success
  it "#{login}では個人登録一覧は#{result}、部署はID=1,本館東3階西" do
    login( login)
    visit "hospital/nurces"
    expect(current_path).to eq "/hospital/nurces"
    expect(page).to have_content("本館東3階西")
    expect(page).to have_content("本館東5階")
    expect(page.has_css?("//option[@value='1'][@selected='selected']")).to be
    expect(page.has_css?("//option[@value='3'][@selected='selected']")).to be_false
  end

  it "個人登録一覧にて、部署をID=3,本館東5階にする" do
    login( login)
    visit "hospital/nurces"
    expect(page.has_css?("//option[@value='1'][@selected='selected']")).to be
    expect(page.has_css?("//option[@value='3'][@selected='selected']")).to be_false

    select "本館東5階"
    click_button "部署変更"
    expect(page.has_css?("//option[@value='3'][@selected='selected']")).to be
    expect(page.has_css?("//option[@value='1'][@selected='selected']")).to be_false
  end


end

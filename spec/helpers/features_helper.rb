# -*- coding: utf-8 -*-
require 'spec_helper'  
def login(username = nil,password=nil)
  username ||= "dezawa"
  password ||= "ug8sau6m"
  find_link("Log out").click if /Log out/ =~ page.body
  
  visit "/users/sign_in" 
  if has_button?("Sign in")
    fill_in 'user_password', with: password
    fill_in 'user_username', with: username
    click_button 'Sign in'
  end
end

def logout
    find_link("Log out").click
end

def page_check(current,all)                  
  expect(page.body).to have_content(" #{all} 次へ 件/ページ")
  expect(page.has_no_link?(" #{current} ")).to be_true
end

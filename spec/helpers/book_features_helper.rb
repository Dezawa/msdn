# -*- coding: utf-8 -*-
require 'spec_helper'  
require 'features_helper'

def visit_book_keeping(username = nil,password=nil)
  username ||= "dezawa"
  password ||= "ug8sau6m"
  find_link("Log out").click if /Log out/ =~ page.body
  
  visit "/users/sign_in" 
  if has_button?("Sign in")
    fill_in 'user_password', with: password
    fill_in 'user_username', with: username
    click_button 'Sign in'
  end
  visit "/book/keeping"
  expect(current_path).to eq "/book/keeping"
end
def year_change(year = 2012)
  find_field("year_owner_year").select(year.to_s)
end

def change_owner(owner)
   click_link("変更")
  current_path.should == "/book/keeping/owner_change_win"
  
  within("tr##{owner}") do
    click_link("選択")
  end
end

def page_check(current,all)                  
  expect(page.body).to have_content(" #{all} 次へ 件/ページ")
  expect(page.has_no_link?(" #{current} ")).to be_true
end

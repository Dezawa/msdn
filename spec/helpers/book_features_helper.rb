# -*- coding: utf-8 -*-
require 'spec_helper'  
def visit_book_keeping(username = nil,password=nil)
  username ||= "dezawa"
  password ||= "ug8sau6m"
  #visit "/users/sign_out"
  #if page.body =~ /Log out/
  #  click_button("Log out")
  #end
  find_link("Log out").click if /Log out/ =~ page.body
  
  visit "/users/sign_in" 
  if has_button?("Sign in")
    fill_in 'user_password', with: password
    fill_in 'user_username', with: username
    click_button 'Sign in'
  end
  visit "/book/keeping"
end
def year_change(year = 2012)
  find_field("year_owner_year").select(year.to_s)
end
def dcookies
  return Capybara.cookies 
  Capcurrent_session.driver.browser.
    current_session.instance_variable_get(:@rack_mock_session).cookie_jar
  Capybara
    .current_session # Capybara::Session
    .driver          # Capybara::RackTest::Driver
    .request         # Rack::Request
    .cookies         # { "author" => "me" }
end

def change_owner(owner)
  current_path.should click_link("変更")
  current_path.should == "/book/keeping/owner_change_win"
  
  within("tr##{owner}") do
    click_link("選択")
  end
end

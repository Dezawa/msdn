# -*- coding: utf-8 -*-
require 'spec_helper'  
      
describe 'トップページ' do  
  specify 'ログインを求められ,パスワードが正しくないとまたログインへ' do  
    visit "/book/keeping"
    current_path.should == "/users/sign_in"
    
#    within('form#new_session') do  
      fill_in 'user_username', with: 'dezawa'  
      fill_in 'user_password', with: 'ug8sau6'  
      click_button 'Sign in'
    current_path.should == "/users/sign_in" #,"パスワードが正しくないとまたログインへ"
 #   end  
  end  

  specify 'ログイン成功すると簿記へ' do                                                    visit "/book/keeping"
      fill_in 'user_username', with: 'dezawa'
      fill_in 'user_password', with: 'ug8sau6m'
      click_button 'Sign in'
    current_path.should == "/book/keeping"
  end
end  

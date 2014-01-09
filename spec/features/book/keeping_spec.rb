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

describe "メインで2012年にした後"  ,js: true do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

  before do
    visit_book_keeping
    year_change
  end

  specify "2012年にできる" do
    page.should have_content("複式簿記：メイン:2012年度")
  end

  specify  "振替伝票 一覧"  do
    page.should have_content("複式簿記：メイン:2012年度")
    
    visit "/book/main"
    current_path.should == "/book/main"
    page.should have_content("振替伝票 一覧")
    page.should have_content("99 99 2012-05-31 2550 旅費交通費 事業主借 東京→小田原 往復")
  end
end

describe "メインで2012年にした後"  ,js: true do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

  before do
    visit_book_keeping
    year_change
  end

  specify "貸借対照表"  do
    page.should have_content("複式簿記：メイン:2012年度")
    visit "/book/keeping/taishaku"
    current_path.should == "/book/keeping/taishaku"
    page.should have_content("利益 -51889")
  end

  specify "科目一覧"  do    
    visit "/book/kamoku"
    current_path.should == "/book/kamoku"
    page.should have_content("3 経費 514 接待交際費")
  end
end


describe 'トップページ' do  
  specify 'ログインを求められ,パスワードが正しくないとまたログインへ' do
    visit "/book/keeping"                         
    fill_in 'user_password', with: 'ug8sau6'
    fill_in 'user_username', with: 'dezawa'
    click_button 'Sign in'
    current_path.should == "/users/sign_in"
    
    #    within('form#new_session') do  
    fill_in 'user_username', with: 'dezawa'  
    fill_in 'user_password', with: 'ug8sau6'  
    click_button 'Sign in'
    current_path.should == "/users/sign_in" #,"パスワードが正しくないとまたログインへ"
    #   end  
  end  

  specify 'ログイン成功すると簿記へ' do
    visit "/book/keeping"
    fill_in 'user_username', with: 'dezawa'
    fill_in 'user_password', with: 'ug8sau6m'
    click_button 'Sign in'
    current_path.should == "/book/keeping"
  end
end  

describe "トップ上での操作" do
  specify "年度初期値は#{Time.now.beginning_of_year}, 2012に変更する" do
    visit_book_keeping
    current_path.should == "/book/keeping"
    #    expect{ find_field("year_owner_year").select("2012")
    expect{year_change }.to change{find_field("year_owner_year").value}.
      from(Time.now.year.to_s).to( "2012")
    current_path.should == "/book/keeping"
    # 
  end
  specify "簿記所有者を変更する" do
    visit_book_keeping
    click_link("変更")
    current_path.should == "/book/keeping/owner_change_win"

    within("tr#aaron") do
      click_link("選択")
    end
    current_path.should == "/book/keeping"
    expect(page).to have_content 'aaronの簿記(編集可能)'
  end


  [["新規伝票作成","/book/main/new"        ],
   ["振替伝票一覧","/book/main"            ],
   ["勘定科目"    ,"/book/kamoku"          ],
   ["貸借対照表"  ,"/book/keeping/taishaku"],
   ["清算表"      ,"/book/keeping/motocho" ],
   ["共有ユーザー","/book/permission"      ]
  ].
    each{|lbl,url|
    specify "#{lbl}画面へ" do
      visit_book_keeping
      within("table#index") do
        click_link(lbl)
      end
      current_path.should == url
    end
  }

  [ ["振替伝票一覧","/book/main/csv_out"            ,"main_index"],
    ["勘定科目"    ,"/book/kamoku/csv_out"          ,"kamoku_index"],
    ["貸借対照表"  ,"/book/keeping/csv_taishaku","keeping_taishaku"],
    ["振替伝票一覧 印刷用CSV","/book/main/csv_out_print","main/csv_out_print"],
    ["勘定元帳一覧 CSV","/book/keeping/csv_motocho","csv_motocho"]
  ].              
    each{|lbl,url,id|
    specify "#{lbl}CSVダウンロード" do
      visit_book_keeping
      click_link(id)
      current_path.should == url
    end

  }

  [["振替伝票一覧","/book/main"   ,"upload_main_index", './test/testdata/book/dezawa_book_main.csv'],
   ["勘定科目"    ,"/book/kamoku" ,"upload_kamoku_index", './test/testdata/book/dezawabook_kamoku.csv']
  ].each{|lbl,url,id,path|
    specify "#{lbl} CSVアップロード" do
      visit_book_keeping
      within("form##{id}" ) do
        #input=find(:input)
        attach_file( id,path)
        click_button("CSVで登録")
      end
      current_path.should == url
    end


  }
end

describe "owner ubeboardにすると" do
  before do
    visit_book_keeping
    change_owner("ubeboard")
  end
  
  specify "一覧は４つ" do
    within("table#index") do
      has_link?("/main/index").should be true  #"振替伝票一覧"
      has_link?("/kamoku/index").should be true  # "勘定科目"
      has_link?("/keeping/taishaku").should be true  #"貸借対照表"
      has_link?("/keeping/motocho").should be true  #"清算表"
      has_no_link?("/main/new").should be true  # 新規
      has_no_link?("/permission/index").should be true  #"清算表"
    end
  end
end


describe "owner aaronにすると" do
  before do
    visit_book_keeping
    change_owner("aaron")
  end
  
  specify "一覧は４つ" do
    within("table#index") do
      has_link?("/main/index").should be true  #"振替伝票一覧"
      has_link?("/kamoku/index").should be true  # "勘定科目"
      has_link?("/keeping/taishaku").should be true  #"貸借対照表"
      has_link?("/keeping/motocho").should be true  #"清算表"
      has_link?("/main/new").should be true  # 新規
      has_no_link?("/permission/index").should be true  #"清算表"
    end
  end
end


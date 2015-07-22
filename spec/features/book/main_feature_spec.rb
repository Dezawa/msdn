# -*- coding: utf-8 -*-
require 'spec_helper'  
require 'book_features_helper'  

describe "新規作成"   do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

  before do
    visit_book_keeping
  end

  specify "新規作成画面に行く" do
    page.should have_content("複式簿記：メイン:")
    visit "/book/main/new"
   current_path.should == "/book/main/new"
  end

  specify "初期値が入る" do
    visit "/book/main/new"
    expect(page.find_field("book_main_date").value).to eq Time.now.strftime("%Y-%m-%d")
    expect(page.find_field("book_main_no").value).to eq "1"
  end


  def set_params_except(item)
    fill_in("book_main_amount",with: 1000 ) unless item == "amount"
    fill_in("book_main_tytle",with: "交通費") unless item == "tytle"
    select("旅費交通費" ,from: "book_main_karikata") unless item == "karikata"
    select( "未払金",from: "book_main_kasikata") unless item == "kasikata"
  end

  specify "必須データを入れると作れる" do
    visit "/book/main/new"
    set_params_except(0)
    expect{ click_button("作成") }.to change{ Book::Main.count }.by(1)
    current_path.should eq "/book/main"
  end

  %w(amount tytle karikata kasikata).each{|item|
    specify "必須データ Item #{item} が欠けると作れない" do
      visit "/book/main/new"
      set_params_except(item)
      expect{ click_button("作成") }.to change{ Book::Main.count }.by(0)
      #page.body.should eq ""
      current_path.should eq "/book/main"
      expect(page.body).to have_content("複式簿記：振替伝票 作成")
      expect( /#{item} .*は必須項目です/i =~ page.body).to be_true
    end
  }
end

describe "2012年の一覧画面 " ,js: true   do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

  before do
    visit_book_keeping
    year_change
    page.should have_content("複式簿記：メイン:2012年度")
  end

  specify "ページ移動" do
    visit("/book/main")
    current_path.should eq "/book/main"
    expect(page.body).to have_content("複式簿記：振替伝票 一覧 2012年度")
    # 10ページ
    expect(page.body).to have_content("前へ 1 2 3 4 5 6 7 8 9 10 次へ 件/ページ")
    # 最初は10頁目
    expect(page.body).to have_content("91 91 2012-05-07 4725 未払金 普通預金")
    # 1ページへ飛ぶ
    click_link("1")
    expect(page.body).to have_content("1 1 2012-01-01 2210614 普通預金 開始残高 開始残高")
    # 次へで
    click_link("次へ")
    expect(page.body).to have_content("11 11 2012-01-15 200 租税公課 事業主借 収入印紙")
    # 前へ で                                                                           
    click_link("前へ")
    expect(page.body).to have_content("1 1 2012-01-01 2210614 普通預金 開始残高 開始残高")
    # 先頭ページには 前へはない
    expect(page.has_no_link?("前へ")).to be_true
  end

  specify "から 新伝票" do
    visit("/book/main")
    current_path.should eq "/book/main"
    expect(page.has_button?("新伝票")).to be_true
    click_button("新伝票")
    current_path.should eq "/book/main/new"
    expect(page.body).to have_content("複式簿記：振替伝票 作成")
  end

  specify "から 整列" do
    visit("/book/main")
    current_path.should eq "/book/main"

    expect(page.body).to have_content("96 96 2012-06-01 11360 接待交際費")
    expect(page.body).to have_content("99 99 2012-05-31 2550 旅費交通費")

    expect(page.has_button?("整列")).to be_true
    click_button("整列")

    expect(page.body).to have_content("96 99 2012-06-01 11360 接待交際費")
    expect(page.body).to have_content("99 98 2012-05-31 2550 旅費交通費")
  end

  specify "から 表編集" do
    visit("/book/main")
    current_path.should eq "/book/main"
    # 一覧での編集に移動
    expect(page.has_button?("編集")).to be_true
    click_button("編集")
    expect(current_path).to eq "/book/main/edit_on_table"
    expect(page.body).to have_content("複式簿記：振替伝票 編集")
    expect(page.has_field?("book_main_91_no")).to be_true
    expect(page.has_select?("book_main_91_kasikata")).to be_true
    expect(page.has_button?("更新")).to be_true
    # データ修正
    fill_in("book_main_91_date",with: "2012-05-05")
    select("旅費交通費",from: "book_main_91_kasikata") 
    click_button("更新")
    click_link("10")
    current_path.should eq "/book/main"
    expect(page.body).to have_content("91 91 2012-05-05 4725 未払金 旅費交通費")
  end

  specify "から 一件編集" do
    # 一覧で ID=92の Editを押す
    visit("/book/main")
    current_path.should eq "/book/main"
    find_by_id('92').click_link("Edit")
    
    # 編集画面がでる
    current_path.should eq "/book/main/92/edit"
    expect(page.has_button?("更新"))
    expect(page.body).to have_content("複式簿記：振替伝票 編集")
    expect(page.has_field?("book_main_no")).to be_true
    expect(page.has_select?("book_main_kasikata")).to be_true

    # データ修正
    fill_in("book_main_date",with: "2012-05-05")
    select("買掛金",from: "book_main_karikata") 
    click_button("更新")
    
    # 一覧画面。全10頁の10頁がでる
    current_path.should eq "/book/main"
    page_check(10,10)
    # 修正されている
    expect(page.body).to have_content("92 92 2012-05-05 6364 買掛金 普通預金")
   #92 92 2012-05-07 6364 未払金 普通預金
  end


end

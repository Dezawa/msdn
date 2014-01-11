# -*- coding: utf-8 -*-
require 'spec_helper'  
require 'book_features_helper'  

describe "科目" ,js: true  do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

  before do
    visit_book_keeping("dezawa","ug8sau6m")
    year_change
    page.should have_content("複式簿記：メイン:2012年度")
    visit "/book/kamoku"
  end

  after do
    click_link "ログアウト"
  end

  specify "画面がでる" do
    expect(current_path).to eq "/book/kamoku"
    expect(page).to have_content("3 経費 514 接待交際費 1")
  end

  specify "dezawa は追加、編集、削除がある" do
    current_path.should eq "/book/kamoku"
    expect(page.has_button?("追加")).to be_true
    expect(page.has_button?("編集")).to be_true
    expect(find_by_id('11').has_link?("削除")).to be_true
  end
 
end
describe "科目画面にて" ,js: true  do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

  before do
    visit_book_keeping
    year_change
    page.should have_content("複式簿記：メイン:2012年度")
    visit "/book/kamoku"
  end

 specify "追加で追加画面がでる" do
    click_button("追加")
    expect(current_path).to eq "/book/kamoku/add_on_table"
    expect(page.has_button?("更新")).to be_true
  end

  specify "追加で空行1行入る" do
    expect{ click_button("追加")}.to change{
      within('table#index_table') do
      page.all('tr').count
      end
    }.by(1)
  end

  specify "追加で2行空行入る" do
    fill_in("book_kamoku_add_no",with: 2)
    expect{ click_button("追加")}.to change{
      within('table#index_table') do
      page.all('tr').count
      end
    }.by(2)
  end

  specify "編集では空行増えない" do
    fill_in("book_kamoku_add_no",with: 2)
    expect{ click_button("編集")}.to change{
      within('table#index_table') do
      page.all('tr').count
      end
    }.by(0)
  end
end

describe "科目" ,js: true  do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

  before do
    visit_book_keeping
    year_change
    page.should have_content("複式簿記：メイン:2012年度")
    visit "/book/kamoku"
  end

  after do
    click_link "ログアウト"
  end


  def fill_in_fields(id,except=[])
    fill_in("book_kamoku_#{id}_bunrui" ,with: 500) unless except.include? :bunrui
    select( "経費",from: "book_kamoku_#{id}_code"  ) unless except.include? :code
    fill_in("book_kamoku_#{id}_kamoku" ,with: "テスト課目") unless except.include? :kamoku
  end

  specify "追加で空行にデータを入れる" do
    # 仮のIDは最大ID+1
    kari_id = Book::Kamoku.maximum(:id)+1
 #   expect{ #課目数 = Book::Kamoku.count
      click_button("追加")
      fill_in_fields(kari_id)
      expect{ click_button("更新")}.to change{
        within('table#index_table') do
          page.all('tr').count
        end
      }.by(0) # 追加の画面で既に1行増えているから増加は０
      
      expect(current_path).to eq "/book/kamoku"
      expect(page.has_css?('div#errors')).not_to be_true
    expect(page.has_button?("編集")).to be_true
      # 一つ増える
#    }.to change{Book::Kamoku.count}.by(1)
  end

  specify "追加で空行にデータを入れる.必須不足のとき" do
    # 仮のIDは最大ID+1
    kari_id = Book::Kamoku.maximum(:id)+1
    課目数 = Book::Kamoku.count
    click_button("追加")
    fill_in_fields(kari_id,[:bunrui])
     click_button("更新")
    
    expect(current_path).to eq "/book/kamoku/update_on_table"
    expect(page.has_css?('div#errors')).to be_true
    # 増えない
    expect(Book::Kamoku.count).to eq 課目数
  end

end

describe "aaronにてlogin" ,js: true  do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

 before do
    visit_book_keeping("aaron","ug8sau6m")
    expect(page).to have_content("aaronの簿記")
  end

  after do
    click_link "ログアウト"
  end


  specify "編集 あり、追加 なし" do
    visit "/book/kamoku"
    expect(page.has_no_button?("追加")).to be_true
    expect(page.has_button?("編集")).to be_true   
  end
end


describe "aaronにてlogin" ,js: true  do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

 before do
    visit_book_keeping("aaron","ug8sau6m")
    expect(page).to have_content("aaronの簿記")
  end

  after do
    click_link "ログアウト"
  end

  specify "編集 あり、追加 なし" do
    visit "/book/kamoku"
    expect(page.has_no_button?("追加")).to be_true
    expect(page.has_button?("編集")).to be_true   
  end

  specify "ubeboardの帳簿だと 編集 なし、追加 なし" do
    change_owner("ubeboard")
    visit "/book/kamoku"
    expect(page.has_no_button?("追加")).to be_true
    expect(page.has_no_button?("編集")).to be_true   
  end

end

describe "課目一覧から元帳へ" ,js: true  do
    fixtures :users,:user_options
    fixtures :user_options_users
    fixtures "book/mains","book/kamokus","book/permissions"

 before do
    visit_book_keeping
    year_change
    page.should have_content("複式簿記：メイン:2012年度")
    expect(page).to have_content("dezawaの簿記")
    find('table#index').click_link("勘定科目")
  end

  after do
    click_link "ログアウト"
  end

  specify "売上" do
    click_link("売上")
    expect(current_path).to eq "/book/main/book_make"
    expect(page).to have_content("売上　(2012年度)")
    within('table#index_table') do
      expect(page.all('tr').count).to eq 3
    end

  end  
end

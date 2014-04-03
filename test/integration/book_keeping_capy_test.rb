# -*- coding: utf-8 -*-
require 'test_helper'
require 'integration_capy_helper'

class BookKeepingCapyTest  < ActionController::IntegrationTest# ActionDispatch::IntegrationTest
  require 'integration_helper'

  fixtures "book/mains","book/kamokus"
  fixtures :users,:user_options,:user_options_users
  fixtures "book/permissions"

  # Replace this with your real tests.
  test "簿記を呼ぶと-0" do
    visit "/book/keeping"
    assert page.has_content?('You need to sign in or sign up before continuing.'),"ログインを求められる"

    login_when_required "dezawa","ug8sau6m"
    assert page.has_content?('Signed in successfully.'), "ログイン成功し"
    assert_equal "/book/keeping", page.current_path,"簿記メインへ飛ぶ"
  end
  Capybara.match=:first
  test "簿記メインメニューから新規作成" do
    visit "/book/keeping"
    #open_book_keeping("dezawa","ug8sau6m")
    click_link("/main/new")
    assert_equal "/book/main/new", page.current_path,"新規作成へ飛ぶ"

    fill_in "book_main_amount",with: 1000
    select( "1", :form =>  "book_main_karikata")
    
  end

  def open_book_keeping(user,pass)
    visit "/book/keeping"
    assert page.has_content?('You need to sign in or sign up before continuing.'),"ログインを求められる"
    login_when_required(user,pass)
    assert_equal "/book/keeping", page.current_path,"簿記メインへ飛ぶ"
  end

  def book_new
    get "/book/main/new"
    assert_response :succes ,"簿記新規作成が開く"
  end
end

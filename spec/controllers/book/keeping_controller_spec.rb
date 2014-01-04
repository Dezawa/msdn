# -*- coding: utf-8 -*-
require 'spec_helper'
require 'controller_helper'
require 'book_helper'
require 'pp'

describe Book::KeepingController,"dezawaでloginすると" do
  fixtures :users,:user_options,:user_options_users
  before do
    login_as("dezawa")
    get :index
  end
  it "年の初期値は#{Time.now.year}" do
    assigns[:year].should eql Time.now.beginning_of_year
    session[:BK_year].should eql Time.now.beginning_of_year
  end
  it "2012年に変更する" do
    expect{post :year_change,:year => "2012"}.to change{session[:BK_year] }.
      from(Time.now.beginning_of_year).to(Time.new(2012,1,1))
  end
  it "参照、利用可能なownerは" do
    assigns[:owner_choices].map(&:last).should eq %w(dezawa aaron guest ubeboard)
    assigns[:owner_choices].should eq [ ["dezawa 編集可能" ,"dezawa"],
                                        ["aaron 編集可能" ,"aaron"],
                                        ["guest 編集可能" ,"guest"],
                                        ["ubeboard 参照のみ","ubeboard"]
                                      ]
  end

  it "owner変更すると" do
    get :owner_change_win
    assigns[:owner_choices].should eq [ ["dezawa 編集可能" ,"dezawa"],
                                        ["aaron 編集可能" ,"aaron"],
                                        ["guest 編集可能" ,"guest"],
                                        ["ubeboard 参照のみ","ubeboard"]
                                      ]
  end

  it "owner aaronを選ぶと" do
    expect{ post( :owner_change,:owner => "aaron")}.
      to change{assigns[:owner].owner}.from("dezawa").to( "aaron")
  end
  
end


describe Book::KeepingController,"dezawaでloginし精算表" do
  fixtures :users,:user_options,:user_options_users
  before do
    login_as("dezawa")
  end

  render_views
  it "精算表表示画面" do
    controller.prepend_view_path 'app/views'
    get :motocho
    expect(response).to render_template("book/keeping/motocho")
    expect(response.body).to_not  match(/href=\"\/book\/keeping\/motocho/),"精算表へのリンクなし"
  end
  
  it "貸借対照表表示画面" do
    controller.prepend_view_path 'app/views'
    get :taishaku
    expect(response).to render_template("book/keeping/taishaku")
    expect(response.body).to_not  match(/href=\"\/book\/keeping\/taishaku/),"貸借対照表へのリンクなし"
  end
  

  
end

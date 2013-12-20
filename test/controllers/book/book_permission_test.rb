# -*- coding: utf-8 -*-
require 'test_helper'
require 'test_book_helper'

class Book::PermissionControllerTest < BookControllerTest
  include Devise::TestHelpers

  Params = { 
    date: Time.utc(2012,10,12),amount: 1000, no: 1,
    karikata: 1, kasikata: 2, tytle: "TESTW"
  }

  @@Users = [:dezawa,:aaron,:quentin]
  @@Model = Book::Main
  @@modelname = @@Model.name.underscore#.to_sym
  @@url_index ="/book/main"
  @@url_pagenate = @@url_index + "?page=%d"
  @@url_create = @@url_index +"?page=6"
  @@count   = "#{@@Model.name}.count"
  @@success  = [:success,true]
  @@redirect = [:redirect,false]
  BookMain=Book::Main
  fixtures "book/mains","book/kamokus"
    
  fixtures :users,:user_options,:user_options_users
  fixtures "book/permissions"

  def setup 
    @controller = Book::MainController.new
    @model = Book::Main.first
  end

  rets = [TTT,TTF,FFF,TTF,TFF,TFF,FFF]
  Users.zip(rets).each{|login,ret|
    must "#{login} が持つ権限 試用、使用、コンフィグは#{ret}" do
      login_as login
      get :index
      assert_equal ret,[assigns["permit"],assigns[:editor],assigns[:configure]]
    end
  }

  right = ["/book/main/owner_change_win", "/book/main", "/book/main"]
  rights = [2,2,1,0,0,0,0] 
  Users.zip(rights).each{|login,ret|
    must "#{login}はdezawaの共有ユーザーか" do
      owner_change(login,"dezawa")
      assert_redirected_to right[ret]
    end
  }

  right = ["/book/main/owner_change_win", "/book/main", "/book/main"]
  rights = [2,2,1,0,0,0,0] 
  Users.zip(rights).each{|login,ret|
    must "#{login}はdezawaの共有ユーザーか" do
      owner_change(login,"dezawa")
      assert_redirected_to right[ret]
    end
  }

  Users.zip([true]*3+[false]*4).each{|login,ret|
    must  "#{login}はdezawaの伝票を読めるか" do
      #login_as login
      assert_equal ret,!!Book::Main.find(1).readable?(login)
    end
  }


  Users.zip([T,T,F,F,F,F,F]).each{|login,ret|
    must  "#{login}はdezawaの伝票を編集できるか" do
      #login_as login
      assert_equal ret,!!Book::Main.find(1).editable?(login)
    end
  }


end

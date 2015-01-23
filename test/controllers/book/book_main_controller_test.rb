# -*- coding: utf-8 -*-
require 'test_helper'
require 'test_book_helper'

class Book::MainControllerTest < BookControllerTest
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
    fixtures "book/mains","book/kamokus","book/permissions"
  
    
  fixtures :users,:user_options,:user_options_users
  fixtures "book/permissions"

  def setup 
    @controller = Book::MainController.new
    #@request = ActionController::TestRequest.new
    #@request.session = ActionController::TestSession.new
    @model = Book::Main.first
  end

  Result = [:success,:success,:success,:success,:success,:success,:redirect]
  Users.zip(Result).each{|login,result|
    must "#{login}では振替伝票一覧は" do
      user = User.find_by(:username => login)
      login_as( login)
#pp user.authenticate!
      get :index
      assert_response result
    end
  }
  Users.zip([:success]*2+[:redirect]+[:success]*3+[:redirect]).
    each{|login,result|
    must "User #{login} は#{@@Model.name}のedit_on_table 可能か results #{result}" do
      login_as (login)
      post :edit_on_table, @@modelname => {@model.id.to_i => @model.attributes}
        assert_response result
      end
    }

  Users.zip([@@url_pagenate%1,@@url_pagenate%1,@@url_permit,
             @@url_pagenate%1,@@url_pagenate%1, @@url_pagenate%1, @@url_error]).
    each{|login,result|
    must "User #{login} は#{@@Model.name}のupdate_on_table, 可能か results #{result}" do
      login_as (login)
      put :update_on_table, @@modelname => {@model.id.to_i => @model.attributes}
        assert_redirected_to result
      end
    }

  Users[SUCCESS].zip([:success]*3+[:redirect]*3).each{|login,result|
    test "ユーザ #{login}は出沢の伝票を表示可能か #{result}" do
    login_as (login)
    get :show, :id => 1
    assert_response result
  end
  }

  Users[SUCCESS].zip([:success]*2+[:redirect]*4).each{|login,result|
    test "ユーザ #{login}は出沢の伝票を編集可能か #{result}" do
    login_as (login)
    get :edit, :id => 1
    assert_response result
  end
  }

  Users[DEZAWA].zip([1,1,0]).each{|login,result|
    test "ユーザ #{login}はowner出沢で伝票を作成(create)可能か #{result}" do
      owner_change(login,"dezawa")
      attributes=@model.attributes
      attributes.delete("id")
      assert_difference(@@count,result) do
        post :create, @@modelname => attributes
      end
    end
  }


#  Users[NO_DZW].each{|login|
#    test "ユーザ #{login}は出沢の伝票を作成(new)可能か " do
#      owner_change(login,"dezawa")
#      post :create, "book/main" => Params.merge( owner: "dezawa")
#      assert_redirected_to "/msg_book_permit.html"
#    end
#  }

 # Users[NO_DZW].each{|login|
 #   test "ユーザ #{login}は出沢の伝票を作成(create)可能か " do
 #     owner_change(login,"dezawa")
 #     post :create ,"book/main" => Params.merge(:owner => "dezawa")
 #     assert_redirected_to "/msg_book_permit.html"
 #   end
 # }

 #            id delta
  Users.zip([ [1,-1] , [1,-1],[1,0],[2,0],[3,0],[3,0],[1,0]]).
    each{|login,id_delta|
    must "User #{login} は#{@@Model.name}:#{id_delta[0]}の削除 可能か" do
      owner_change(login,"dezawa")
      assert_difference "Book::Main.count",id_delta[1] do
        put :destroy, :id =>  id_delta[0]
      end
    end
  }

  Users[DEZAWA].zip([-1,-1,0]).each{|login,result|
    test "ユーザ #{login}は出沢の伝票を削除可能か #{result}" do
      owner_change(login,"dezawa")
      assert_difference "Book::Main.count",result do
        put :destroy, :id =>  1
      end
    end
  }

  Users[NO_DZW].each{|login|
    test "ユーザ #{login}は出沢の伝票を削除可能か " do
      owner_change(login,"dezawa")
      assert_difference "Book::Main.count",0 do
        put :destroy, :id =>  1
      end
    end
  }

  Users[SUCCESS].zip([T,T,F,F,F,F,F]).each{|login,result|
    test "ユーザ #{login}は出沢の伝票editableか #{result}" do
      owner_change(login,"dezawa")
      assert_equal result, assigns[:owner].owner == "dezawa" && @controller.editable
    end
  }

    must "ユーザ dezawaは出沢の伝票を一覧編集可能か " do
      owner_change("aaron","dezawa")
      get :update_on_table, @@modelname => {@model.id.to_i => @model.attributes}
      assert_redirected_to @@url_pagenate%1
    end

    must "ユーザ aaronは出沢の伝票を一覧編集可能か " do
      owner_change("aaron","dezawa")
      get :update_on_table, @@modelname => {@model.id.to_i => @model.attributes}
      assert_redirected_to @@url_pagenate%1
    end

    must "ユーザ quentin は出沢の伝票を一覧編集可能か " do
      owner_change("quentin","dezawa")
      get :update_on_table, @@modelname => {@model.id.to_i => @model.attributes}
      assert_redirected_to @@url_permit
    end

  test "伝票作成必須項目" do
    login_as "dezawa"
    get :new
    post :create, "book/main" => {date: "2012/10/10"}
    assert  assigns[:model].errors[:date].size ==0    ,"日付は必須"
    assert  assigns[:model].errors[:kasikata].size>0,"貸し方は必須"
    assert  assigns[:model].errors[:karikata].size>0,"借り方は必須"
    assert  assigns[:model].errors[:amount].size>0  ,"金額は必須" 
    assert  assigns[:model].errors[:tytle].size>0   ,"備考は必須"
  end

  test "伝票一覧" do
    login_as ("dezawa")
    get :index
    assert_response 200
    assert 0,assigns[:models].size

    assert_equal Time.now.year,session[:BK_year].year
    session[:BK_year]
  end

  
end

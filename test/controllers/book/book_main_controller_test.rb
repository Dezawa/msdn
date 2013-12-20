require 'test_helper'
require 'test_book_helper'

class BookMainControllerTest < BookControllerTest
  include AuthenticatedTestHelper

  @@Users = [:dezawa,:aaron,:quentin]
    @@Model = Book::Main
    @@modelname = @@Model.name.underscore.to_sym
  @@url_index ="/#{@@Model.name.underscore.sub(/\//,"_")}"
  @@url_pagenate = @@url_index + "?page=%d"
  @@url_create = @@url_index +"?page=6"
  @@count   = "#{@@Model.name}.count"
  @@success  = [:success,true]
  @@redirect = [:redirect,false]
  BookMain=Book::Main
  if Rails.version < "3"
    fixtures "book_mains","book_kamokus"
  elsif Rails.version > "3"
    fixtures "book/mains","book/kamokus"
  end
    
  fixtures :users,:user_options,:user_options_users
  fixtures :book_permissions

  def setup 
    @controller = BookMainController.new
    @request = ActionController::TestRequest.new
    @request.session = ActionController::TestSession.new
    @model = Book::Main.first
  end

  Result = [:success,:success,:success,:success,:success,:success,:redirect]
  Users.zip(Result).each{|login,result|
    must "#{login}では振替伝票一覧は" do
      login_as login
      get :index
      assert_response result
    end
  }

  Users.zip([:success]*2+[:redirect]+[:success]*3+[:redirect]).
    each{|login,result|
    must "User #{login} は#{@@Model.name}のedit_on_table 可能か results #{result}" do
      login_as (login)
      put :edit_on_table, @@modelname => {@model.id.to_i => @model.attributes}
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


  Users[DEZAWA].zip([:success]*2).each{|login,result|
    test "ユーザ #{login}は出沢の伝票を作成(new)可能か #{result}" do
      owner_change(login,"dezawa")
      get :new
      assert_equal "dezawa",assigns(:owner).owner
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

  Users[NO_DZW].each{|login|
    test "ユーザ #{login}は出沢の伝票を作成(new)可能か " do
      owner_change(login,"dezawa")
      get :new
      assert_redirected_to "/msg_book_permit.html"
    end
  }


  Users[NO_DZW].each{|login|
    test "ユーザ #{login}は出沢の伝票を作成(create)可能か " do
      owner_change(login,"dezawa")
      get :create
      assert_redirected_to "/msg_book_permit.html"
    end
  }

 #            id delta
  Users.zip([ [1,-1] , [2,-1],[1,0],[4,-1],[3,-1],[3,-1],[1,0]]).
    each{|login,id_delta|
    must "User #{login} は#{@@Model.name}の削除 可能か" do
      login_as (login)
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

  Users[SUCCESS].zip([:success]*2+[:redirect]*4).each{|login,result|
    test "ユーザ #{login}は出沢の伝票の一覧編集画面がでるか #{result}" do
      owner_change(login,"dezawa")
      get :edit_on_table
      assert_response result
    end
  }

  Users.
    zip([@@url_pagenate%1,@@url_pagenate%1,
         @@url_permit,@@url_permit,@@url_permit,
         @@url_permit,@@url_error]).
    each{|login,result|
    must "ユーザ #{login}は出沢の伝票を一覧編集可能か #{result}" do
      owner_change(login,"dezawa")
      get :update_on_table, @@modelname => {@model.id.to_i => @model.attributes}
      assert_redirected_to result
    end
  }

end

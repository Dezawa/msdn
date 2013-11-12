require 'test_helper'
require 'test_book_helper'

class BookKamokuControllerTest <  BookControllerTest
  include AuthenticatedTestHelper
  @@Users = [:dezawa,:aaron,:quentin]
    @@Model = Book::Kamoku
    @@modelname = @@Model.name.underscore.to_sym
  @@url_index ="/#{@@Model.name.underscore.sub(/\//,"_")}"
  @@url_pagenate = @@url_index + "?page=%d"
  #@@url_error    = "/msg_book_permit.html"
  @@url_create = @@url_index +""
  @@count   = "#{@@Model.name}.count"
  @@success  = [:success,true]
  @@redirect = [:redirect,false]
  BookKamoku=Book::Kamoku
  if Rails.version < "3"
    fixtures :book_kamokus,:book_permissions,:book_mains
  elsif Rails.version > "3"
    fixtures "book/kamokus"
  end

  fixtures :users,:user_options,:user_options_users
  def setup
    @controller = BookKamokuController.new
    @request = ActionController::TestRequest.new
    @request.session = ActionController::TestSession.new
    @model = Book::Kamoku.first #nd(1) 
    #@model = book_kamokus(:one)
  end

  Users.zip([:success,:success,:success,:success,:success,:success,:redirect]).each{|login,result|
    must "#{login}では科目の一覧がでる" do
      login_as login
      get :index
      assert_response result
    end
  }

  
 # Result = 
  Users.zip([:success,:success,:redirect,:success,:success,:success,:redirect]).each{|login,result|
    must "#{login}では科目の一覧更新画面は" do
      login_as login
      put :edit_on_table
      assert_response result
    end
  }

  Users.zip( [@@url_pagenate%1,@@url_pagenate%1,@@url_permit,
              @@url_pagenate%1,@@url_pagenate%1,@@url_pagenate%1,@@url_error]).each{|login,result|
    must "#{login}では科目の一覧更新は" do
      login_as login
      put :update_on_table , @@modelname => {@model.id.to_i => @model.attributes}
        assert_redirected_to result
    end
  }


  Users.zip([:success]+[:redirect]*6).each{|login,result|
    must "科目の新規作成は configureが必要なので#{login}で新規画面は" do
      login_as login
      get :new
      assert_response result
    end
  }


  Users.zip([1,0,0,0,0,0,0]).each{|login,result|
    must "科目の新規作成は configureが必要なので#{login}では" do
      login_as login
      attributes=@model.attributes
      attributes.delete("id")
      assert_difference(@@count,result) do
        post :create, @@modelname => attributes
      end
      #assert_redirected_to result
    end
  }


  Users.zip([-1,0,0,0,0,0,0]).each{|login,result|
    must "科目の削除は configureが必要なので#{login}では" do
      login_as login
      assert_difference(@@count,result) do
         delete :destroy, :id => @model.id
      end
      #assert_redirected_to result
    end
  }

  Users[SUCCESS].zip([3,18,18,18,18,18]).each{|login,kamoku|
    test "ユーザ#{login}のときの最初の科目は" do
      login_as login
      get :index
      assert_equal kamoku,assigns["models"].first.id
    end
  }

  Users[0..2].zip([3,3,3]).each{|login,kamoku|
    test "ユーザ#{login}が出沢の簿記を観るときの最初の科目は" do
      owner_change( login,"dezawa")
      get :index
      assert_equal kamoku,assigns["models"].first.id
    end
  }

  test "出沢のときは追加がある" do
    login_as "dezawa"
    get :index
    assert_tag :tag => "form",:attributes => { :action =>"/book_kamoku/add_on_table" }
  end
  
  Users[1..5].each{|login|
    test "#{login}のときは追加がない" do
      login_as login
      get :index
      assert_no_tag :tag => "form",:attributes => { :action =>"/book_kamoku/add_on_table" }
    end
  }
  
  test "出沢のとき、編集がある。これは全編集" do
    login_as "dezawa"
    get :index
    assert_tag :tag => "form",:attributes => { :action =>"/book_kamoku/edit_on_table_all_column" }
  end
  
  test "quentinとき、編集はない" do
    login_as "quentin"
    get :index
    assert_no_tag :tag => "form",:attributes => { :action =>"/book_kamoku/edit_on_table" }
  end
  
  %w(aaron  ubeboard  guest  testuser).each{|login|
    test "#{login}のとき、編集がある" do
      login_as login
      get :index
#pp (assigns["owner"].permission == 2 )
      assert_tag :tag => "form",:attributes => { :action =>"/book_kamoku/edit_on_table" }
    end
  }
end


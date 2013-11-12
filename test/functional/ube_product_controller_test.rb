require 'test_helper'

class UbeProductControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  @@Model = UbeProduct
  @@model_size = 77
  @@Controller = UbeProductController
  def model_by_sym(sym); ube_products(:one) ;end
  AttrMerge = {}
  fixtures :ube_products #meigaras, :ube_products,:ube_operations

  @@Users = [:dezawa,:ubeboard,:guest]
  @@modelname = @@Model.name.underscore.to_sym #:ube_product
  @@url_index ="/#{@@Model.name.underscore}"
  @@url_create = @@url_index +"?page=4"
  @@missing_url= '/404.html'
  @@count   = "#{@@Model.name}.count"
  @@success =[:success,true]
  @@redirect=[:redirect,false]
  @@missing =[:missing,'/404.html',false]

  fixtures :users,:user_options,:user_options_users

  def setup 
    @controller =  @@Controller.new
    @request = ActionController::TestRequest.new
    @request.session = ActionController::TestSession.new
    @model = @@Model.find 1
  end

  must "#@@Model.name}.couont is " do
    assert_equal @@model_size, @@Model.count
  end

  @@Users.zip([[:success,true],@@success,@@redirect]).each{|login,result|
    test "ユーザー #{login} は #{@@Model.name}の index に #{result[0]}" do
      login_as (login)
      get :index
      assert_response result[0]
      assert_equal result[1], !!assigns(:models)
    end
  }


  @@Users.zip([[:success,true],@@success,@@redirect]).each{|login,result|
    test "ユーザー #{login} は show #{@@Model.name} に #{result[0]}" do
    login_as (login)
    get :show, :id => @model
    assert_response result[0]
  end
  }

  @@Users.zip([[:success,true],@@success,[:redirect,false]]).each{|login,result|
    test " ユーザ #{login} は new #{@@Model.name} に#{result[0]}" do
    login_as (login)
    get :new
    assert_response result[0]
  end
  }

  @@Users.zip([[1,@@url_create],[1,@@url_create],[0,@@missing_url]]).each{|login,result|
    test "  ユーザ #{login}が #{@@Model.name} create に#{result[0]}" do
    login_as (login)
      attributes=@model.attributes.merge AttrMerge
      attributes.delete("id")
      assert_difference(@@count, result[0]) do
        post :create, @@modelname => attributes
      end
      assert_redirected_to result[1] 
    end
  }

  @@Users.zip([:success,:success,:redirect]).each{|login,result|
    test " User #{login} get edit #{@@Model.name} results #{result}" do
    login_as (login)
    get :edit, :id => @model
    assert_response result
  end
  }

  @@Users.zip([@@url_index,@@url_index,"/404.html"]).each{|login,result|
    test " User #{login} update #{@@Model.name} results #{result}" do
    login_as (login)
    put :update, :id => @model, @@Model.name => @model.attributes
    assert_redirected_to result
  end
  }

  @@Users.zip([[-1,@@url_index],[-1,@@url_index],[0,"/404.html"]]).each{|login,result|
    test " User #{login} destroy #{@@Model.name} results difference is #{result}" do
    login_as (login)
    assert_difference(@@count, result[0]) do
      delete :destroy, :id => @model
    end
    
    assert_redirected_to result[1]
  end
    }
  ###

  @@Users[0..1].each{|login,result|
    test " ユーザ #{login} indexで[追加]が #{result}" do
      login_as (login)
      get :index 
      assert_tag  :tag => "form",:attributes => {:action =>"/#{@@modelname}/add_on_table" }
    end
  }
  @@Users[0..1].each{|login,result|
    test " ユーザ #{login} indexで[編集]が #{result}" do
      login_as (login)
      get :index 
      assert_tag  :tag => "form",:attributes => {:action =>"/#{@@modelname}/edit_on_table?page=1"}
    end
  }
  @@Users[0..1].each{|login,result|
    test " ユーザ #{login} indexで[行編集]が #{result}" do
      login_as (login)
      get :index 
      assert_no_tag  :tag => "td"  , :child => { :tag => "a",:attributes => {:href =>"/#{@@modelname}/1/edit?page=1"}}
    end
  }
  @@Users[0..1].each{|login,result|
    test " ユーザ #{login} indexで[行表示]が #{result}" do
      login_as (login)
      get :index 
      assert_no_tag  :tag => "td"  ,:child => { :tag => "a",:attributes => {:href =>"/#{@@modelname}/1"},:child => "Show"}
      #assert_tag  :tag => "td"  ,:child => { :tag => "a",:child => "Show"}
    end
  }
  @@Users[0..1].each{|login,result|
    test " ユーザ #{login} indexで[行削除]が #{result}" do
      login_as (login)
      get :index 
      assert_tag  :tag => "td"  ,:child => { :tag => "a",:attributes => {:href =>"/#{@@modelname}/1",:onclick => /delete/ }}#,:child =>"削除"}
    end
  }
end

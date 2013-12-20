require 'test_helper'

class UbeChangeTimesControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
    @@Model = UbeChangeTime
  @@Controller =UbeChangeTimesController
  def model_by_sym(sym); ube_change_times(:one) ;end
  AttrMerge = {}

  fixtures :ube_change_times

  @@Users = [:dezawa,:ubeboard,:guest]
  @@modelname = @@Model.name.underscore.to_sym #:ube_product
  @@url_index ="/#{@@Model.name.underscore}s"
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
    @model = @@Model.first
  end


  @@Users.zip([@@url_index,@@url_index,"/404.html"]).each{|login,result|
    test "User #{login} update_on_table #{@@Model.name} results #{result}" do
    login_as (login)
      put :update_on_table, :changetime => {@model.id.to_i => @model.attributes}
    assert_redirected_to result
  end
  }

  @@Users.zip([[:success,true],[:success,true],[:redirect,false]]).each{|login,result|
    test " should #{login} get  #{@@Model.name} index results #{result[0]}" do
      login_as (login)
      get :index
      assert_response result[0]
      assert_equal result[1], !!assigns(:models)
    end
  }

  #@@Users.zip([[:success,true],[:success,true],[:redirect,false]]).each{|login,result|
  #  test " should #{login} show #{@@Model.name} results #{result[0]}" do
  #  login_as (login)
  #  get :show, :id => @model
  #  assert_response result[0]
  #end
  #}

  #@@Users.zip([[:success,true],[:success,true],[:redirect,false]]).each{|login,result|
  #  test " User #{login} get new  #{@@Model.name} results #{result[0]}" do
  #  login_as (login)
  #  get :new
  #  assert_response result[0]
  #end
  #}
  #@@Users.zip([[1,@@url_create],[1,@@url_create],[0,"/404.html"]]).each{|login,result|
  #  test " User #{login} create #{@@Model.name} results  difference is #{result[0]}" do
  #  login_as (login)
  #    attributes=@model.attributes
  #    attributes.delete("id")
  #    assert_difference('UbeMeigara.count',result[0]) do
  #      post :create, @@modelname => attributes
  #    end
  #    assert_redirected_to result[1] 
  #  end
  #}
  @@Users.zip([:success,:success,:redirect]).each{|login,result|
    test "User #{login} get edit #{@@Model.name} results #{result}" do
    login_as (login)
    get :edit_on_table, :id => @model
    assert_response result
  end
  }
  #@@Users.zip([[-1,@@url_index],[-1,@@url_index],[0,"/404.html"]]).each{|login,result|
  #  test "User #{login} destroy #{@@Model.name} results difference is #{result}" do
  #  login_as (login)
  #  assert_difference(@@count, result[0]) do
  #    delete :destroy, :id => @model
  #  end
  #  
  #  assert_redirected_to result[1]
  #end
  #  }
end

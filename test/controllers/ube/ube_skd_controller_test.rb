# -*- coding: utf-8 -*-
require 'test_helper'

class UbeSkdControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  @@Model = Ubeboard::Skd
  @@Controller=Ubeboard::SkdController
  fixtures "ube/skds","ube/plans","ube/plans_skds","ube/products","ube/operations" #meigaras, :ube_products","ube_operations"
  def model_by_sym(sym); ube_skds(:one) ;end
  AttrMerge = {"skd_from" => "2012/9/1","skd_to"=>"2012/9/30","replan_from"=>"2012/9/10",
    :skd_from => "2012/9/1",:skd_to=>"2012/9/30",:replan_from=>"2012/9/10",
  }

  @@Users = [:dezawa,:ubeboard,:guest]
  @@modelname = "ube_skd" #@@Model.name.underscore.to_sym #:ube_product
  @@url_index ="/#{@@Model.name.underscore}"
  @@url_create = @@url_index +"?page=1"
  @@missing_url= '/404.html'
  @@count   = "#{@@Model.name}.count"
  @@success =[:success,:show]
  @@redirect=[:redirect,false]
  @@missing =[:missing,'/404.html',false]

  fixtures :users,:user_options,:user_options_users

  def setup 
    @controller =  @@Controller.new
    #@request = ActionController::TestRequest.new
    #@request.session = ActionController::TestSession.new
    @model = @@Model.find 1
  end


  @@Users.zip([:success,:success,:redirect]).each{|login,result|
    test " User #{login} update #{@@Model.name} results #{result}" do
      login_as (login)
      attributes = @model.attributes.merge(AttrMerge)
      Ubeboard::SkdController::RunTimeSyms.each{|sym| s=sym.to_s;attributes[s] = attributes[s].to_s if attributes[s]}
      put( :update, :id => @model, 
           @@modelname => attributes,
           :ube_plan =>  @model.ube_plans.map{|plan| plan.attributes }
           )
      assert_response result
    end
  }


  @@Users.zip([:success,:success,:redirect]).each{|login,result|
    test " User #{login} get edit #{@@Model.name} results #{result}" do
    login_as (login)
    get :edit, :id => @model
    assert_response result
  end
  }

  @@Users.zip([[:success,true],[:success,true],@@redirect]).each{|login,result|
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

  @@Users.zip([[1,:success],[1,:success],[0,:redirect]]).each{|login,result|
    test "  ユーザ #{login}が #{@@Model.name} create に#{result[0]}" do
    login_as (login)
      attributes=@model.attributes.merge(AttrMerge)
      Ubeboard::SkdController::RunTimeSyms.each{|sym| s=sym.to_s;attributes[s] = attributes[s].to_s if attributes[s]}
 
      attributes.delete("id")
#pp attributes
      assert_difference(@@count, result[0]) do
        post :create, @@modelname => attributes
      end
      assert_response result[1] 
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
end

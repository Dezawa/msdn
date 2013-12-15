# -*- coding: utf-8 -*-
require 'test_helper'

class LipsControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  @@Model = Lips
  @@model_size = 60
  @@Controller = LipsController
  def model_by_sym(sym); ube_operations(:one) ;end
  AttrMerge = {}
  #fixtures :ube_operations #meigaras, :ube_operations,:ube_operations

  @@Users = [:dezawa,:ubeboard,:guest]
  @@modelname = @@Model.name.underscore.to_sym #:ube_operation
  @@url_index ="/#{@@Model.name.underscore}"
  @@url_create = @@url_index# +"?page=4"
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
    #@model = @@Model.find 1
  end

  Users = %w(ubeboard guest)
  
  Users.zip( %w(汎用会員版 無償版)).each{|login,reg|
    test "ユーザー #{login} は #{reg}" do
    login_as (login)
    get :calc
      assert_tag  :tag => "b",:child => /#{reg}/
  end
  }

  Users.zip( [:assert_no_tag,:assert_tag]).each{|login,assert|
    test "ユーザー #{login} は #{assert}" do
      login_as (login)
      get :calc
      send assert  ,  :tag => "td",:child => /線型計画といえば製造計画/
  end
  }
  [:csv_upload,:change_form].each{|comm|
  Users.zip( [:success,:redirect]).each{|login,res|
      test "ユーザー #{login}の #{comm} は #{res}" do
      login_as (login)
      get comm
      assert_response res
  end
  }
  }
end

# -*- coding: utf-8 -*-
require 'test_helper'

class UbeConstantControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  @@Model = Ubeboard::Constant
  @@Controller = Ubeboard::ConstantController
  def model_by_sym(sym); ube_skds(:one) ;end
  AttrMerge = {}
  fixtures "ube/constants" #meigaras, :ube_products,:ube_operations
  fixtures :users,:user_options,:user_options_users

  @@Users = [:dezawa,:ubeboard,:guest]
  @@modelname = @@Model.name.underscore.to_sym #:ube_product
  @@url_index ="/#{@@Model.name.underscore}"
  @@url_create = @@url_index +"?page=1"
  @@missing_url= '/404.html'
  @@count   = "#{@@Model.name}.count"
  @@success =[:success,:show]
  @@redirect=[:redirect,false]
  @@missing =[:missing,'/404.html',false]


  def setup 
    @controller =  @@Controller.new
    #@request = ActionController::TestRequest.new
    #@request.session = ActionController::TestSession.new
    @model = @@Model.first
  end

  must "#@@Model.name}.couont is " do
    assert_equal 13, @@Model.count
  end

  @@Users.zip([[:success,true],[:success,true],@@redirect]).each{|login,result|
    test "ユーザー #{login} は #{@@Model.name}の index に #{result[0]}" do
      login_as (login)
      get :index
      assert_response result[0]
      assert_equal result[1], !!assigns(:models)
    end
  }


  @@Users.zip([[:success,true],[:redirect,false],[:redirect,false]]).each{|login,result|
    test " ユーザ #{login} は new #{@@Model.name} に#{result[0]}" do
    login_as (login)
    get :new
    assert_response result[0]
  end
  }

  @@Users.zip([[1,@@url_create],[0,@@missing_url],[0,@@missing_url]]).each{|login,result|
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

  @@Users.zip([:success,:redirect,:redirect]).each{|login,result|
    test " User #{login} get edit #{@@Model.name} results #{result}" do
    login_as (login)
    get :edit, :id => @model
    assert_response result
  end
  }

  @@Users.zip([@@url_index,"/404.html","/404.html"]).each{|login,result|
    test " User #{login} update #{@@Model.name} results #{result}" do
    login_as (login)
    put :update, :id => @model, @@Model.name => @model.attributes
    assert_redirected_to result
  end
  }

  @@Users.zip([[-1,@@url_index],[0,"/404.html"],[0,"/404.html"]]).each{|login,result|
    test " User #{login} destroy #{@@Model.name} results difference is #{result}" do
    login_as (login)
    assert_difference(@@count, result[0]) do
      delete :destroy, :id => @model
    end
    
    assert_redirected_to result[1]
    end
  }


  ["kakou_result_copy","SHOZOW_UNKYU_ENDING"].each{|lbl|
    must "UbeConstant#edit_on_table ユーザdezawa 編集時は入力エリアに値 #{lbl}あり" do
      login_as("dezawa")
      get :edit_on_table
      assert_tag :tag => "tr",:child => {:tag => "td",
        :child =>  {:tag => 'input' ,:attributes => { :value => lbl }
        }
      }
    end
  }


    must "UbeConstant#edit_on_table  ユーザubeboard　編集時 の SHOZOW_UNKYU_ENDING は表示" do
      login_as("ubeboard")
      get :edit_on_table
      assert_tag :tag => "tr",:child => {:tag => "td",
        :child => "SHOZOW_UNKYU_ENDING"
      }
    end

  %w( Key 管理者項目).each{|lbl|
    must "UbeConstant#edit_on_table  ユーザdezawa　編集時 の欄#{lbl}あり" do
      login_as("dezawa")
      get :edit_on_table
      assert_tag :tag => "tr",:child => {:tag => "td",
        :child => lbl
      }
    end
  }

  %w( Key 管理者項目).each{|lbl|
    must "UbeConstant#edit_on_table  ユーザubeboard　編集時 の欄#{lbl}なし" do
      login_as("ubeboard")
      get :edit_on_table
      assert_no_tag :tag => "tr",:child => {:tag => "td",
        :child => lbl
      }
    end
  }

  %w( Key 管理者項目 kakou_result_copy).each{|lbl|
    must "UbeConstant#index ユーザdezawa 欄#{lbl}あり" do
      login_as("dezawa")
      get :index
      assert_tag :tag => "tr",:child => {:tag => "td",
        :child => lbl
      }
    end
  }
  %w( Key 管理者項目 kakou_result_copy).each{|lbl|
    must "UbeConstant ユーザubeboad 欄#{lbl}あり" do
      login_as("ubeboard")
      get :index
      assert_no_tag :tag => "tr",:child => {:tag => "td",
        :child => lbl
      }
    end
  }
end

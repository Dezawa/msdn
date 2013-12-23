# -*- coding: utf-8 -*-
require 'test_helper'
require 'test_book_helper'

class BookKeepingControllerTest < BookControllerTest
  include Devise::TestHelpers
  # Replace this with your real tests.
  @@Controller =  Book::KeepingController

  fixtures :users,:user_options,:user_options_users
  fixtures "book/permissions"

  Result = [:success,:success,:success,:success,:success,:success,:redirect]
  Choise = [ #dezawa
            [["dezawa 編集可能", "dezawa"],["aaron 編集可能","aaron"],["guest 編集可能", "guest"],
             ["ubeboard 参照のみ","ubeboard"]],
            #aaron
            [["aaron 編集可能","aaron"], ["dezawa 編集可能", "dezawa"],["guest 編集可能", "guest"],
             ["ubeboard 参照のみ","ubeboard"]],
            #quentin
            [["ubeboard 参照のみ","ubeboard"],["dezawa 参照のみ","dezawa"]],
            #ubeboard
            [ ["ubeboard 編集可能","ubeboard"],["guest 編集可能", "guest"]],
            [["guest 編集可能", "guest"]],
            [["guest 編集可能", "guest"]]
           ]

  def setup
    @controller = @@Controller.new
    #@request    = ActionController::TestRequest.new
    #@response   = ActionController::TestResponse.new
  end

  Users[SUCCESS].zip([4,4,2,2,1,1]).each{|login,count|
    test "#{login}のアクセス権の数は" do
      login_as login
      get :index
      assert_equal count,assigns["arrowed"].size
      end
    }
  Users[0..3].each{|login|
    must "二つ以上アクセス権のある#{login}は、owner変更の選択肢が出る" do
      login_as  login
      get :index
      assert_tag(:tag => "a",
                 :attributes => { :href => "/book/keeping/owner_change_win?popup=true"}
                 )
    end
  }
  Users[4..5].each{|login|
    must "アクセス権が一つ」な#{login}は、owner変更の選択肢が出ない" do
      login_as login
      get :index
      assert_no_tag(:tag => "a",
                 :attributes => { :href => "/book/keeping/owner_change_win?popup=true"}
                 )
    end
  }
  must "BookKeeping Top without login is redirect 'login'" do
    get :index
    assert_redirected_to "/users/sign_in"
  end

  must "BookKeeping Top login as old_password_holder 複式簿記 is rejected " do
    login_as "old_password_holder"
    get :index
    assert_redirected_to "/book/keeping/error"
  end

  Users[SUCCESS].
    zip([%w(dezawa 編集可能),%w(aaron 編集可能),%w(ubeboard 参照のみ),
         %w(ubeboard 編集可能),%w(guest 編集可能),%w(guest 編集可能)]).
    each{|login,owner_perm|
    must "#{login}のときは、defaultのownerは#{owner_perm}" do
      login_as login
      get :index
      assert_equal(owner_perm,assigns(:owner).owner_permission)
    end
  }

  # indexが開くか
  Users.zip(Result).each{|user,result|
    must "BookKeeping Top for #{user} は " do
      login_as user
      get :index
      assert_response result
    end
  }

  #振替伝票一覧 印刷用CSVがひらくか
  # indexが開くか
  Users[SUCCESS].zip(Result[SUCCESS]).each{|user,result|
    must "BookKeeping Top for #{user} の振替伝票一覧 印刷用CSVがひらくか " do
      login_as user
      get :index
      assert_tag(:tag => "div",
                 :child => {:tag => "a",:attributes => { :href => "/book/main/csv_out_print"} }
                 )
    end
  }

  @@Controller::Labels.each{|menu| 
    must "出沢のとき、BookKeeping Top menu のline #{menu.label}はある" do
      login_as("dezawa")
      get :index
      assert_tag :tag => "tr",:descendant => menu.label
    end
  }

  @@Controller::Labels.each{|menu| 
    must "出沢のとき、BookKeeping Top menu #{menu.label} link toはある" do
      login_as("dezawa")
      href = "/book/"+menu.model.to_s + (menu.action == :index ? "" : "/#{menu.action}")
      get :index
      assert_tag :tag => "tr",#, #child => {:tag => "td",
        :descendant => {:tag => "a",:attributes => { :href => href }}
      #}
    end
  }

  @@Controller::Labels.each{|menu| next unless menu.enable_csv_upload
    must "出沢のとき、BookKeeping Top menu #{menu.label} csv upload" do
      login_as("dezawa")
      href = "/book/#{menu.model}/#{menu.csv_upload_action}"
      get :index
      assert_tag :tag => "tr",:descendant => {:tag => "form",
        :attributes => { :action => href }
      }
    end
  }

  @@Controller::Labels.each{|menu| next unless menu.csv_download_url
    must "BookKeeping Top menu #{menu.label} csv download" do
      login_as("dezawa")
      href = case menu.csv_download_url
             when Symbol ;"/book/#{menu.model}/#{menu.csv_download_url}"
             when String ; menu.csv_download_url
             else ; ""
             end
      get :index
      assert_tag :tag => "tr",
        :descendant => {
        :tag => "a",
        :attributes => { :href => href }
        }#}
    end
  }
  
  Users[SUCCESS].zip(Choise).each{|login,choise|
    must "#{login}のときのowner選択肢は" do
      login_as login
      get :index
      assert_equal choise,assigns(:owner_choices)
    end
  }



  must "出沢のとき、quentin を共有ユーザに指定するとエラー" do
    login_as("dezawa")
    get :owner_change, :owner => "quentin"
    assert_equal "許可の無いユーザです",flash[:error]
  end

  %w(aaron ubeboard).each{|owner|
    must "出沢のときのowner選択を#{owner}としたとき共有ユーザーは出ない" do
      login_as("dezawa")
      get :owner_change, :owner => owner
      get :index
      assert_no_tag :tag => "tr",#:child => {:tag => "td",
        :descendant => {:tag => "a",:attributes => { :href => "/book/permission" }}

    end
  }
end

class Book::Permission < ActiveRecord::Base
  def owner_permission
   [owner,permission_string]
end
end

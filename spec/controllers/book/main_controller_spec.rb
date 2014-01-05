# -*- coding: utf-8 -*-
require 'spec_helper'
require 'book_helper'
require 'controller_helper'
require 'pp'


URL_index ="/book/main"
URL_pagenate = URL_index + "?page=%d"
URL_create   = URL_index + "?page=6"

 describe Book::MainController,"一覧画面" do
  fixtures :users,:user_options,:user_options_users
  fixtures "book/mains","book/kamokus"

   Result = [:success,:success,:success,:success,:success,:success,:redirect]
   Users.zip(Result).each{|login,result|
     it "#{login}では振替伝票一覧は#{result}" do
       login_as( login)
       get :index
       assert_response result
     end
   }
   
   describe "edit_on_table" do
     Users.zip([:success]*2+[:redirect]+[:success]*3+[:redirect]).
       each{|login,result|
       it "User #{login} は" do
         login_as (login)
         post :edit_on_table #, :book_main => {@model.id.to_i => @model.attributes}
         assert_response result," 可能か results #{result}"
         #expect(flash).to eq([]),"flashは"
       end
     }
   end
  
  before do
    @model=Book::Main.find(1)
  end
  Users.zip([URL_pagenate%1,URL_pagenate%1,URL_permit,
             URL_pagenate%1,URL_pagenate%1, URL_pagenate%1, URL_error]).
    each{|login,result|
    it "User #{login} は Book::Mainのupdate_on_table, 可能か results #{result}" do
      login_as (login)
      put :update_on_table, "book/main" => {@model.id.to_i => @model.attributes}
        assert_redirected_to result
      end
    }

end

describe Book::MainController,"一覧画面にて on 2012年" do
  fixtures :users,:user_options,:user_options_users
  fixtures "book/mains","book/kamokus"

  before do
    login_as "dezawa"
    session[:BK_year] = Time.new(2012,1,1)
    get :index
  end

  it "100件あるから" do
    #assert_response :success
    assigns[:page].should eq(10),"10paqge"
    assigns[:models].should have(10).items,"表示は10件"
  end
  
  it "1件めID=1 の金額変更" do
    get "edit", id: 1
    expect(response).to render_template("application/edit_vertical")
    expect{post "update",id: 1, "book/main" =>{amount: 10000}}.to change{Book::Main.find(1).amount}.
      from(2210614).to(10000)
  end
  it "1件めID=1 の表示" do
    get "show", id: 1
    expect(response).to render_template("application/show")
  end

  it "1件めID=1 の削除" do
    expect{delete "destroy", id: 1}.to change{Book::Main.count}.
      from(106).to(105)
    expect(response).to redirect_to("/book/main")
  end

  
end

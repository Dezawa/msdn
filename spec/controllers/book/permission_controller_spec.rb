# -*- coding: utf-8 -*-
require 'spec_helper'
require 'controller_helper'
require 'book_helper'
require 'pp'


describe Book::KeepingController,"権限" do
  Users.zip(Permissions).each{|user,permission|
    it "#{user}の権限は ${permission} " do
      login_as(user)
      get :index
      assigns[:permissions].should eql permission
    end
  }
end

describe Book::KeepingController,"他人の帳簿を読む権限あるとき" do
  fixtures :users,:user_options,:user_options_users
  
  owner="dezawa"
  user = "aaron"
  it "#{user} は#{owner}の帳簿を使えるか" do
    login_as(user)
    post :owner_change,owner: owner
    expect( assigns[:arrowed]).to have(4).items
    expect( assigns[:arrowed].map(&:owner)).to eq %w(aaron dezawa guest ubeboard)
    expect( assigns[:owner].owner).to eql owner
    expect(response).to redirect_to("/book/keeping")
  end
  
end



describe Book::KeepingController,"他人の帳簿を読む権限ないとき" do
  fixtures :users,:user_options,:user_options_users
  user = "aaron"
  owner="testuser"
  it "#{user} は#{owner}の帳簿を使えるか" do
    login_as(user)
    post :owner_change,owner: owner
    expect( assigns[:arrowed]).to have(4).items
    expect( assigns[:arrowed].map(&:owner)).to eq %w(aaron dezawa guest ubeboard)
    expect( assigns[:owner].owner).to eql user
    expect(response).to redirect_to("/book/keeping/owner_change_win")
    #expect(response).to render_template("index")
  end

end

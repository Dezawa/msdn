# -*- coding: utf-8 -*-
require 'spec_helper'
require 'controller_helper'
require 'book_helper'
require 'pp'


describe Book::KeepingController,"権限" do
  fixtures :users,:user_options,:user_options_users

  

  user = "aaron"
  it "#{user} はdezawaの帳簿を使えるか" do
    login_as(user)
    post :owner_change,owner: "dezawa"
    expect( assigns[:arrowed]).to have(4).items
    expect( assigns[:arrowed].map(&:owner)).to eq %w(aaron dezawa guest ubeboard)
    expect( assigns[:owner].owner).to eql "dezawa"
    expect(session[:BK_owner]).to be assigns[:owner].id
    expect(response).to be_redirect#success #response.status.should == 302
    
      expect(response).to render_template("index")
  end

end

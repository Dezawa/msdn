# -*- coding: utf-8 -*-
require 'spec_helper'
require 'book_helper'
require 'controller_helper'
require 'pp'

include Devise::TestHelpers
 def dlogin_as(username)
    @user = User.find_by(username: username)
    sign_in :user,@user
  end

describe Book::MainController,"権限確認" do
  fixtures :users,:user_options,:user_options_users
    #login_as("dezawa")
   it "dezawa権限は TTT" do
     login_as("dezawa")
     get :index
     response.status.should be(200)
     assigns[:permissions].should eql TTT
   end

end
 

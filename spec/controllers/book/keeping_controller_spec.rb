# -*- coding: utf-8 -*-
require 'spec_helper'
require 'controller_helper'
require 'book_helper'
require 'pp'


describe Book::KeepingController,"権限" do
  fixtures :users,:user_options,:user_options_users

  Users.zip(Permissions).each{|user,permission|
    it "#{user}の権限は ${permission} " do
      login_as(user)
      get :index
      assigns[:permissions].should eql permission
    end
  }
  it "年の初期値は#{Time.now.year}" do
    login_as("dezawa")
    get :index
    assigns[:year].should eql Time.now.beginning_of_year
  end
end

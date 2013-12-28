# -*- coding: utf-8 -*-
require 'spec_helper'
require 'pp'

describe User do
 fixtures :users
 describe "create :" do
    context "normal case." do
      it "not null" do
        @user = create_user
        @user.errors.should nil
      end
    end
    context "必須項目不足" do
      it "password_confirmation" do
        @user = create_user( :password_confirmation => nil)
        @user.errors[:password_confirmation].should == ["can't be blank"]
      end
    end
  end   
end

  def create_user(options = {})
    record = User.new({ :username => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end

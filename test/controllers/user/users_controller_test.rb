# -*- coding: utf-8 -*-
require 'test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end


class UsersControllerTest < ActionController::TestCase
  # Then, you can remove it from this and the units test.
  include Devise::TestHelpers

  fixtures :users,:user_options,:user_options_users

  def test_should_allow_create_new_user_by_dezawa
    login_as("dezawa")
    assert_difference 'User.count',1 do
      create_user 
    end
  end

  def test_should_not_arrow_create_new_user_by_quentin
    login_as("quentin")
    #assert_
    assert_no_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_username_on_create_new_user
    login_as("dezawa")
    assert_no_difference 'User.count' do
      create_user(:username => nil)
    end
       assert assigns["user"].errors[:username].size>0
      assert_response :success
 end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      login_as("dezawa")
      create_user(:password => nil)
      assert assigns("user").errors[:password].size>0
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      login_as("dezawa")
      create_user(:password_confirmation => nil)
      assert assigns("user").errors[:password_confirmation].size > 0
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      login_as("dezawa")
      create_user(:email => nil)
      assert assigns("user").errors[:email]
      assert_response :success
    end
  end
  

    def test_dezawa_index_show
      login_as("dezawa")
      get :index 
      assert_tag  :tag => "td"  ,:child => { :tag => "a",:attributes => {:href =>"/users/1"},:child => "表示"}
    end
  

  protected
    def create_user(options = {})
      post :create, :user => { :username => 'quire', :email => 'quire@example.com',
        :password => 'quire6999', :password_confirmation => 'quire6999' }.merge(options)
    end
end

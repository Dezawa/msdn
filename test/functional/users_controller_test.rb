require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users,:user_options,:user_options_users

  def test_should_allow_create_new_user_by_dezawa
    assert_difference 'User.count' do
      login_as("dezawa")
      create_user
      assert_response :redirect
    end
  end

  def test_should_not_arrow_create_new_user_by_quentin
    assert_no_difference 'User.count' do
      login_as("quentin")
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      login_as("dezawa")
      create_user(:login => nil)
      assert assigns["user"].errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      login_as("dezawa")
      create_user(:password => nil)
      assert assigns("user").errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      login_as("dezawa")
      create_user(:password_confirmation => nil)
      assert assigns("user").errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      login_as("dezawa")
      create_user(:email => nil)
      assert assigns("user").errors.on(:email)
      assert_response :success
    end
  end
  

    def test_dezawa_index_show
      login_as ("dezawa")
      get :index 
      assert_tag  :tag => "td"  ,:child => { :tag => "a",:attributes => {:href =>"/users/1"},:child => "表示"}
    end
  

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire6999', :password_confirmation => 'quire6999' }.merge(options)
    end
end

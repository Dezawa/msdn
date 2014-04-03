# -*- coding: euc-jp -*-

require "test_helper"
require "capybara/rails"

    module ActionController
      class IntegrationTest
        include Capybara

        def login_when_required(user, password)
           fill_in 'user_username', :with => user
           fill_in 'Password', :with => password
           click_link_or_button('Sign in')
          assert page.has_content?('Signed in successfully'), "ログイン成功"
        end

        def login_as(user, password)
           #user = User.create(:password => password, :password_confirmation => password, :email => user)
           #user.confirmed_at = Time.now 
           #user.save!
           visit '/' #users/sign_in'
           click_link('Sign in')
           fill_in 'user_username', :with => user
           fill_in 'Password', :with => password
           click_link_or_button('Sign in')
         end 
         def sign_out
            click_link('Log out')   
         end
      end
    end

    def login(username,password)
      post user_session_path, {:user => {:username => username,      :password => password}}
    end

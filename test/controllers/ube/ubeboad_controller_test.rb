# -*- coding: utf-8 -*-
#
require 'test_helper'

class UbeboardControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  # Replace this with your real tests.
  @@Controller = Ubeboard::TopController

  fixtures :users,:user_options,:user_options_users
  

  def setup
    @controller = @@Controller.new
    #@request    = ActionController::TestRequest.new
    #@response   = ActionController::TestResponse.new
  end

  must "Ubeboard Top without login is redirect 'login'" do
    get :top
    assert_redirected_to "/users/sign_in"
  end

  must "Ubeboard Top for aaron is rejected " do
    login_as "aaron"
    get :top
    assert_redirected_to "/404.html"
  end

  must "Ubeboard Top for quentin has not 記名メンテ " do
    login_as "quentin"
    get :top
    assert_no_tag :tag => 'tr',:attributes => { :id => 'ube_named_changes'}
  end

  must "Ubeboard Top for quentin has not  工程管理項目" do
    login_as "quentin"
    get :top
    assert_no_tag :tag => 'tr',:attributes => { :id => 'ube_constant'}
  end

  @@Controller::Labels.each{|menu| 
    must "Ubeboad Top menu line #{menu.label}" do
      login_as("dezawa")
      get :top
      assert_tag :tag => "tr",:attributes => {:id => menu.model.to_s}
    end
  }

  @@Controller::Labels.each{|menu| 
    must "Ubeboad Top menu #{menu.label} link to" do
      login_as("dezawa")
      href = "/ubeboard/"+menu.model.to_s + (menu.action == :index ? "" : "/#{menu.action}")
      get :top
      assert_tag :tag => "tr",#:child => {:tag => "td",
        :descendant => {:tag => "a",:attributes => { :href => href }}
      
    end
}

  @@Controller::Labels.each{|menu| next unless menu.enable_csv_upload
    must "Ubeboad Top menu #{menu.label} csv upload" do
      login_as("dezawa")
      href = "/ubeboard/#{menu.model}/#{menu.csv_upload_action}"
      get :top
      assert_tag :tag => "tr",:descendant => {:tag => "form",
        :attributes => { :action => href }
      }
    end
  }

  @@Controller::Labels.each{|menu| next if menu.enable_csv_upload
    must "Ubeboad Top menu #{menu.label} csv upload" do
      login_as("dezawa")
      href = "/ubeboard/#{menu.model}/#{menu.csv_upload_action}"
      get :top
      assert_no_tag :tag => "tr",:descendant => {:tag => "form",
        :attributes => { :action => href }
      }
    end
  }

  @@Controller::Labels.each{|menu| next unless menu.csv_download_url
    must "Ubeboad Top menu #{menu.label} csv download" do
      login_as("dezawa")
      href = case menu.csv_download_url
             when Symbol ;"/ubeboard/#{menu.model}/#{menu.csv_download_url}"
             when String ; menu.csv_download_url
             else ; ""
             end
      get :top
      assert_tag :tag => "tr",
        :descendant => {
        :tag => "a",
        :attributes => { :href => href }
        }
    end
  }

end


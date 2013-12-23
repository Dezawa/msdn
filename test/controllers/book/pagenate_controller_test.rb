# -*- coding: utf-8 -*-
require 'test_helper'
class PagenateControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  @@Model = Book::Main
  @@modelname = @@Model.name.underscore.to_sym
  tests Book::MainController
  fixtures "book/mains","book/kamokus"
  fixtures "book/permissions"
  fixtures :users,:user_options,:user_options_users
  def setup
    @controller = Book::MainController.new
    #@request = ActionController::TestRequest.new
    #@request.session = ActionController::TestSession.new
    login_as "dezawa"
    get :index
    session[:BK_year] = Time.parse("2012/1/1") 
  end

  test "ページあたり件数変更の表示がでる" do
    #login_as "dezawa"
    get :index
    assert_tag :tag => "form" , :attributes => { :action => '/book/main/change_per_page' }
  end

  test "ページ切り替えがでる" do
    #login_as "dezawa"
    get :index

    assert_tag :input ,:attributes => { :type => 'hidden', :name => 'page', :value => '10'}
    assert_tag :tag => "a" , :attributes  => {:href =>"/book/main?page=9",:class => "previous_page"}
  end

  test "ページあたり20件にすると、最終ページは5" do
    #login_as "dezawa"
    get :index
     pp assigns["models"].map(&:id).sort

    #assert_equal 100,assigns["models"].size,"Date number is"
    assert_tag :input ,:attributes => { :type => 'hidden', :name => 'page', :value => '10'}
    put :change_per_page,:line_per_page => 20
    get :index
    assert_equal 20,session["BKMain_per_page"]
    assert_tag :input ,:attributes => { :type => 'hidden', :name => 'page', :value => '5'}
    assert_tag :tag => "a" , :attributes  => {:href =>"/book/main?page=4",:class => "previous_page"}
  end

  test "6ページ表示時にページあたり20件にすると、表示ページは3" do
    #login_as "dezawa"
    get :index,:page => 6
    assert_tag :input ,:attributes => { :type => 'hidden', :name => 'page', :value => '6'}
    put :change_per_page,:line_per_page => 20,:page=>6
    #get :index
   # assert_equal 20,session["BKMain_per_page"]
    assert_tag :input ,:attributes => { :type => 'hidden', :name => 'page', :value => '3'}
  end

  [[1,1],[2,1],[3,2],[4,2]].each{|pre,post|
    test "#{pre}ページ表示時に20件/pageにすると#{post}ページになる" do
      #login_as "dezawa"
      get :index,:page => pre
      put :change_per_page,:line_per_page => 20,:page => pre
      assert_equal post,assigns["page"]
    end
  }


  [[1,1],[2,3],[3,5],[4,7]].each{|pre,post|
    test "20件/ページで#{pre}ページ表示時に10件/pageにすると#{post}ページになる" do
      #login_as "dezawa"
      get :index,:page => pre
      put :change_per_page,:line_per_page => 20,:page => pre
      put :change_per_page,:line_per_page => 10,:page => pre
      assert_equal post,assigns["page"]
    end
  }

end

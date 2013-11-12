# -*- coding: utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'pp'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  def self.must(name,&block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
    defined = instanth_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block
      define_method(test_name,block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end

  end
  def times(str)
    str.split(",").map{|tstr| Time.parse("2012/"+tstr)}
  end
end
class String
  def times; self.split(/[ ,]+/).map{|tstr| Time.parse("2012/"+tstr+" +9:00")};end
end
class Time
def mdHM
  strftime("%m/%d-%H:%M")
end
def inspect;self.strftime("%m/%d-%H:%M");end
end

class UbeSkd
  def assign_force(plan,real_ope,force_from_time)
    maint = [force_from_time,force_from_time,[]]
    assign = temp_assign_plan_shozo_kakou(plan,real_ope,force_from_time,maint[1])
    assign_maint_plan_by_temp(plan,real_ope,[maint,assign])
  end
end

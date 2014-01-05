ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
$LOAD_PATH << File.join(File.dirname(__FILE__),"helpers")


  TTT=[true, true, true]
  TTF=[true, true,false]
  TFF=[true,false,false]
  FFF=[false]*3
  NNN=[nil]*3

Dezawa = "dezawa"
class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

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

  def login_as(login)
      user = User.find_by(:username => login)
      sign_in( user)
  end

  def times(*timestrings)
    timestrings.map{|str| Time.parse(str) }
  end

 def assert_equal_array(expected,actual,labels=nil,msg=nil)
   labels = (0..expected.size-1).to_a  unless labels && labels.size>0
   labels.each_with_index{|label,idx|
     assert_equal( expected[idx],actual[idx],"#{msg}: #{label}: ")
   }
 end
 def assert_equal_array_array(expectedaa,actual,labels=nil,msg=nil)
   expectedaa.each_with_index{|expecteda,idx|
     expecteda.each_with_index{|expected,jdx|
       assert_equal( expected,actual[idx][jdx],"#{msg}: #{idx}:#{jdx} ")
     }
   }
 end
end

class Time
def dmdHM
  strftime("%m/%d-%H:%M")
end
def dinspect;self.strftime("%Y/%m/%d-%H:%M");end
end

class ActiveSupport::TimeWithZone
def dmdHM
  strftime("%m/%d-%H:%M")
end
def dinspect;self.strftime("%Y/%m/%d-%H:%M");end
end

class String
  def times; self.split(/[ ,]+/).map{|tstr| Time.parse("2012/"+tstr+" +9:00")};end
end

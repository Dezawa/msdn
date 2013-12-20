# -*- coding: utf-8 -*-
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :users


protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end

end

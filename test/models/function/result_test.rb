# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
class Function::ResultTest < ActiveSupport::TestCase
  %w( 2W0496N1○ 2W0497N1○ 9Ｍ9999 9ｍ9999 8Ｗ8888 8ｗ8888 9M9999 9m9999 8W8888 8w8888 5m666 ).
    zip( %w( 2W0496 2W0497 9M9999   9M9999  8W8888  8W8888  9M9999 9M9999 8W8888 8W8888) << nil).each{|lot,nom|
    must " lot_no #{lot} must be normalized to #{nom}" do
      assert_equal nom,skd=Ubeboard::Skd.new.normalize_lotno(lot)
    end
  }
end

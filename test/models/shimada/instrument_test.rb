# -*- coding: utf-8 -*-
# -*- coding: undecided -*-
require 'test_helper'

class Shimada::InstrumentTest < ActiveSupport::TestCase
  fixtures "shimada/instrument"
  must "工場ID=1の装置は" do
    assert_equal 3,Shimada::Instrument.by_factory_id(1).size
  end
  must "工場中部シマダヤの装置は" do
    assert_equal 3,Shimada::Instrument.by_factory_name('中部シマダヤ').size
  end
end

require 'test_helper'

class Hospital::WantTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

def n_c(ary1,ary2,num,&block)
  ary2.combination(num){|c| block.call(c)}
end
def n_cp(ary1,ary2,num,&block)
  ary2.combination(num){|c| ary1.each{|a| bleck.call([a]+c)}}
end

n_c([1,2],[3,4,5,6,7],2){|c| p c}


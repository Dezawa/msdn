require 'test_helper'

class Hospital::NeedTest < ActiveSupport::TestCase
  fixtures :hospital_needs
  # Replace this with your real tests.

  must "remake combination3 after save" do
    need = Hospital::Need.new("daytype"=>1,"busho_id"=>3,"role_id"=>3,"kinmucode_id"=>2,"minimun"=>1,"maximum"=>1)
    need.save
    pp Hospital::Need.all( :conditions => ["minimun>0"]).map(&:role_id).uniq.sort
    
    assert_equal [1,2,3,4,5],Hospital::Need.roles,"Need.roles"
    assert_equal 10*6,Hospital::Need.combination3.size
  end
  must  "a self.combination3" do
    assert_equal [ [1,2,4],[1,4,2],[2,1,4],[2,4,1],[4,1,2],[4,2,1],
                   [1,2,5],[1,5,2],[2,1,5],[2,5,1],[5,1,2],[5,2,1],
                   [1,4,5],[1,5,4],[4,1,5],[4,5,1],[5,1,4],[5,4,1],
                   [2,4,5],[2,5,4],[4,2,5],[4,5,2],[5,2,4],[5,4,2]
                 ].sort,Hospital::Need.combination3
  end

  must "Need.roles " do
    assert_equal [1,2,4,5],Hospital::Need.roles.sort
  end
end

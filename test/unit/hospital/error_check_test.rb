require 'test_helper'
#require 'need'

class Hospital::ErrorCheckTest < ActiveSupport::TestCase
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes
  # Replace this with your real tests.
  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(@busho_id,@month)
  end

  private
  def nurce(id);n= Hospital::Nurce.find id
    n.monthly(@month)
    n
  end

end

__END__

  must "喜津直美は３超過" do
    @assign.assign_month
    assert_equal [["喜津直\347\276\216", "深夜が2を越え\343\201\237",
                   4, "033002503300_____310____________0"]
                 ],@assign.nurces[2].error_check
  end

  must "看護師全部では" do
    @assign.assign_month
    assert_equal [],@assign.error_nurces
  end
  must "日のチェック" do
    @assign.assign_month
    assert_equal [],@assign.error_days
  end

  must "error" do
    @assign.assign_month
    @assign.error_check
  end

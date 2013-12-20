# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
#require 'result_copy_data.rb'
class Function::MaintainTest < ActiveSupport::TestCase
  fixtures "ube/products","ube/operations" #,:ube_holydays,:ube_maintains,:ube_maintains
  must "Maintain.null " do
    null=Ubeboard::Function::Maintain.null
    assert_equal [0,[nil]],[null.periad,null.hozen_code_list]
  end

  must "new" do
    me = Ubeboard::Function::Maintain.new([ 10,[20]])
    assert_equal [10,[20]],[me.periad,me.hozen_code_list]
  end
  must "Add " do
    me = Ubeboard::Function::Maintain.new([ 10,[20]])
    other = Ubeboard::Function::Maintain.new([ 30,[40]])
    added = me+other
    assert_equal [40,[20,40]],[added.periad,added.hozen_code_list]
  end
  must "Add null" do
    me = Ubeboard::Function::Maintain.new([ 10,[20]])
    other = Ubeboard::Function::Maintain.null
    added = me+other
    assert_equal [10,[20]],added.to_a
  end

  must "Add not null " do
    me = Ubeboard::Function::Maintain.new([ 10,[20]])
    other = Ubeboard::Function::Maintain.new([ 20,[30]])
    added = me+other
    assert_equal [30,[20,30]],added.to_a #[added.periad,added.hozen_code_list]
  end
  must "Longer " do
    me = Ubeboard::Function::Maintain.new([ 10,[20]])
    other = Ubeboard::Function::Maintain.new([ 20,[30]])
    added = me.longer other
    assert_equal [20,[20,30]],added.to_a
  end
    
  must "hozen_data('PF替',real_ope)" do
    skd=Ubeboard::Skd.new
    assert_equal [86400.0, [116]],Ubeboard::Function::Maintain.hozen_data('PF替',:shozow).to_a
  end

  must "Ubeboard::Function::Maintain.hozen_data酸洗" do
    skd=Ubeboard::Skd.new
    assert_equal [7200.0, [105]],Ubeboard::Function::Maintain.hozen_data("酸洗",:shozow).to_a
  end
end

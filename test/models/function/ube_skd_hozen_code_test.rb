# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdHozenCodeTest < ActiveSupport::TestCase
  fixtures "ube/products","ube/operations","ube/plans"
  #Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
end

__END__

ube_named_change.rb:54:     hozen_names = Hash[*UbeProduct.find(:all,:conditions => "ope_condition like 'A%'").map{|op|
ube_named_change.rb:64:           print ids.map{|id| hozen_names[id]}.join(" ")+sep
ube_plan.rb:180:    if  !hozen?              && !!plan_dry_from && !! plan_shozo_to && 
ube_skd.rb:235:    @hozen ||= Hash.new{|h,k| h[k]=0}
function/ube_skd_freelist.rb:119:  def assign_maint(real_ope,start,stop,array_hozen_code,option={})
function/ube_skd_freelist.rb:127:    return unless array_hozen_code && array_hozen_code[0]
function/ube_skd_freelist.rb:136:    array_hozen_code.each{|pro_id|
function/ube_skd_freelist.rb:138:      plan = create_hozen_plan(real_ope,start,stop,pro_id,jun)  if lot_no

function/ube_skd_help.rb:241:  def hozen_code(hozen,real_ope=nil)
function/ube_skd_help.rb:242:    @hozen_code ||= Hash.new
function/ube_skd_help.rb:243:    unless @hozen_code[[hozen,real_ope]]
function/ube_skd_help.rb:244:      case hozen
function/ube_skd_help.rb:247:        #when :yobouhozen,"予防保全"
function/ube_skd_help.rb:251:          up = UbeProduct.find_by_proname_and_shozo(hozen,UbeSkd::Id2RealName[real_ope])
function/ube_skd_help.rb:253:          up = UbeProduct.find_by_proname_and_dryer(hozen,UbeSkd::Id2RealName[real_ope])
function/ube_skd_help.rb:257:          up = UbeProduct.find_by_proname(hozen)
function/ube_skd_help.rb:260:      @hozen_code[[hozen,real_ope]] =  up ? [up.id,up.ope_condition,real_ope] : nil
function/ube_skd_help.rb:262:    @hozen_code[[hozen,real_ope]] 
function/ube_skd_help.rb:267:  def hozen_data(hozen,real_ope=nil)
function/ube_skd_help.rb:268:    @hozen_data ||= Hash.new
function/ube_skd_help.rb:269:    unless @hozen_data[[hozen,real_ope]]
function/ube_skd_help.rb:270:      hozencode = hozen_code(hozen,real_ope)
function/ube_skd_help.rb:271:      @hozen_data[[hozen,real_ope]] = hozencode ? [hozen_periad[hozencode],[hozencode[0]],nil] : [0,[nil],nil]
function/ube_skd_help.rb:273:    @hozen_data[[hozen,real_ope]]
function/ube_skd_help.rb:323:  #* Key は hozen_code
function/ube_skd_help.rb:325:  def hozen_periad  # k = hozen_code == [28, "A02", :shozow]
function/ube_skd_help.rb:326:    @hozen_periad ||= Hash.new{|h,k|
function/ube_skd_help.rb:428:      [hozen_data("WF替",real_ope)]
function/ube_skd_help.rb:430:      [hozen_data("WF替",real_ope)]
function/ube_skd_help.rb:438:      [hozen_data("PF替",real_ope)]
function/ube_skd_help.rb:449:        hozen_date[:kakou] != ope_to.day #&&  # まだ予防保全してない
function/ube_skd_help.rb:450:      hozen_data("予防保全",real_ope)[0..1]
function/ube_skd_help.rb:463:    logger.debug("TAAP do_sansen? hozen_date #{ hozen_date[real_ope]} 抄造日#{date}")
function/ube_skd_help.rb:464:    hozen_date[real_ope] != date && 
function/ube_skd_help.rb:544:    sorted_plan[1].select{|plan| !plan.hozen? && plan.next_ope == :kakou
function/ube_skd_help.rb:550:    sorted_plan[1].select{|plan| plan.next_ope == :dry && !plan.hozen? 
function/ube_skd_help.rb:565:    sorted_plan[1].each{|plan| next unless plan.current == :shozo && !plan.hozen?
function/ube_skd_help.rb:677:      hd = hozen_data("酸洗",plan.shozo?)
function/ube_skd_help.rb:688:        #hozen_date[real_ope]=shozo_plan[0].day
function/ube_skd_help.rb:722:    sansen_hozen_data = hozen_data("酸洗",real_ope)
function/ube_skd_help.rb:730:      unless  (shozo_maint[1]-shozo_maint[0]) >= sansen_hozen_data[0]
function/ube_skd_help.rb:732:        start,stop = freeList[real_ope].searchfree(pre_condition[real_ope].plan_shozo_to,sansen_hozen_data[0],true)
function/ube_skd_help.rb:734:        shozo_maint=sansen = [start,stop,sansen_hozen_data[1]]
function/ube_skd_help.rb:742:      #hozen_date[real_ope]=shozo_plan[0].day
function/ube_skd_help.rb:817:  # <tt>戻り値</tt>      :: ［start,stop,hozencode]
function/ube_skd_help.rb:818:  #                     :: hozencode は [ube_product_id]
function/ube_skd_help.rb:859:      array_hozencode = hozencode_arrange(change[1])
function/ube_skd_help.rb:861:                "#{start.mdHM}～#{stop.mdHM} [#{array_hozencode.join(',')}]") if start
function/ube_skd_help.rb:862:    start ? [start,stop,array_hozencode] : nil
function/ube_skd_help.rb:878:    periad,array_hozencode = longer_change_maint(plan,real_ope)
function/ube_skd_help.rb:880:    start ? [start,stop,hozencode_arrange(array_hozencode)] : nil
function/ube_skd_help.rb:1011:      !plan.result_done? && !plan.hozen? || 
function/ube_skd_help.rb:1012:      plan.hozen? && plan.included(time_from,time_to) 
function/ube_skd_help.rb:1069:        plan = create_hozen_plan(real_ope,start,stop,hc[0])
function/ube_skd_help.rb:1075:        plan = create_hozen_plan(real_ope,plan_start,plan_end,hc[0])
function/ube_skd_help.rb:1254:  def hozencode_arrange(array_hozencode)
function/ube_skd_help.rb:1255:    return ["切替"] if array_hozencode.size ==0
function/ube_skd_help.rb:1256:    if (array_hozencode & UbeSkd.named_mult).size >0
function/ube_skd_help.rb:1257:      array_hozencode & UbeSkd.named_mult
function/ube_skd_help.rb:1259:      array_hozencode
function/ube_skd_help.rb:1267:    hozencode = hozencode1 =( change[1]+ maintain[1]).compact
function/ube_skd_help.rb:1268:    [ [change[0], maintain[0]].max,hozencode ]

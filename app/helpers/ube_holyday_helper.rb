# -*- coding: utf-8 -*-
module UbeHolydayHelper
  def my_select_box(model,sym,option={} ) # option :id,:index,:value
    #<select name='model[id][sym][index]'>
    #<option value='0' selected><option value='1'>休日<option value='2'>休出<option value='3'>過労働</select>
    id = option[:id] ; index=option[:index]
    name="'#{model}[#{id}][#{sym}][#{index}]'"
    sel=[""]*5 ; v=option[:value].to_i;sel[v]="selected"
    "<select name=#{name}>"+
      "<option value='0' #{sel[0]}><option value='1' #{sel[1]}>休日<option value='2' #{sel[2]}>休出"+
      "<option value='3' #{sel[3]}>過労働<option value='4' #{sel[4]}>運休</select>"
  end
end

# -*- coding: utf-8 -*-
require 'test_helper'

ResultWhenNoOption =
  ["","form action=\"temperatuer\" accept-charset=\"UTF-8\" method=\"post\"",
   "input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" ",
   "input type='hidden' name='page' value=''",
   "input type=\"submit\" name=\"commit\" value=\"label\" ",
   "/form"]
   
ResultEdit =
  ["",'form class="button_to" method="get" action="/weather_location/edit_on_table?page=1"',
   'input type="submit" value="編集" ','/form']
ResultAddOn =["", "form action=\"/weather_location/add_on_table\" accept-charset=\"UTF-8\" method=\"post\"", "input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" ", "input type='hidden' name='page' value='1'", "input type=\"submit\" name=\"commit\" value=\"追加\" ", "input size=\"2\" value=\"1\" type=\"text\" name=\"weather_location[add_no]\" id=\"weather_location_add_no\" ", "/form", "/td", "td"]
ResultAddOnTable =
  ["","form action=\"weather_location\" accept-charset=\"UTF-8\" method=\"post\"",
   "input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" ",
   "input type='hidden' name='page' value=''",
   "input type=\"submit\" name=\"commit\" value=\"label\" ",
   "/form"]

class ApplicationHelperTest < ActionView::TestCase
  include ActionButtonHelper
  def form_authenticity_token
    "form_authenticity_token"
  end

  must "creating a link weather " do
    assert_dom_equal '<a href="/weather">show</a>',
      link_to("show",controller: :weather)
  end
  must "creating a link weather humidity" do
    assert_dom_equal '<a href="/weather/humidity">humidity</a>',
      link_to("humidity",controller: :weather,action: :humidity)
  end
  must "creating a link weather temperatuer" do
    assert_dom_equal '<a href="/weather/temperatuer">show</a>',
      link_to("show",controller: :weather,action: :temperatuer)
  end
  must "form_buttom option なし" do
    assert_equal '<form action="/weather/temperatuer" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" />', form_tag( controller: :weather,action: "temperatuer")
    #assert_equal ResultWhenNoOption, form_buttom( :show,"label")
  end
  must "form_buttom option method: :get" do
    expect = ResultWhenNoOption.dup
    expect[1]=expect[1].sub(/post/,"get")
    assert_equal expect,form_buttom( 'temperatuer',"label",method: :get).split(/\/?[<>]+/)
  end
  must "form_buttom page=3" do
    @page=3
    expects = ResultWhenNoOption.dup
    expects[3]=expects[3].sub(/''/,"'3'")
    assert_equal expects,
      form_buttom(  'temperatuer',"label",action: "temperatuer").split(/\/?[<>]+/)
    #assert_equal ResultWhenNoOption, form_buttom( :show,"label")
  end
  must "form_buttom form_notclose" do
    assert_equal 5,
      form_buttom( 'temperatuer',"label",action: "temperatuer",form_notclose: true).split(/\/?[<>]+/).size
    #assert_equal ResultWhenNoOption, form_buttom( :show,"label")
  end
  ########## Edit On Table ###
  must "add on table " do
    @page = 1
    assert_equal ResultAddOn, add_buttom( :weather_location,controller: :weather_location).split(/\/?[<>]+/)
 end
  must "edit on table " do
    @page = 1
    assert_equal ResultEdit, edit_buttom( controller: :weather_location).split(/\/?[<>]+/)
 end
  must "edit on tables " do
    @page = 1
    assert_equal ResultAddOn+ResultEdit[1..-1], edit_buttoms( :weather_location,controller: :weather_location).split(/\/?[<>]+/)
 end
  ########## CSV ############
  must "upload_buttom " do
    @page = 1
    @Domain = "weather_location"
    assert_equal ["", "form enctype=\"multipart/form-data\" action=\"/weather_location/csv_upload\""+
                  " accept-charset=\"UTF-8\" method=\"post\"",
                  "input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" ",
                  "input type=\"submit\" name=\"commit\" value=\"CSV_UPLOAD\" ",
                  "input type=\"file\" name=\"weather_location[uploadfile]\""+
                    " id=\"weather_location_uploadfile\" ",
                  "/form"],
      upload_buttom("csv_upload","CSV_UPLOAD").split(/\/?[<>]+/)
  end
  must "CSVUP " do
    @page = 1
    @Domain = "weather_location"
    assert_equal ["", "form enctype=\"multipart/form-data\" action=\"/weather_location/csv_upload\""+
                  " accept-charset=\"UTF-8\" method=\"post\"",
                  "input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" ",
                  "input type=\"submit\" name=\"commit\" value=\"CSVで登録\" ",
                  "input type=\"file\" name=\"weather_location[csvfile]\" id=\"weather_location_csvfile\" ",
                  "/form"],
      csv_up_buttom.split(/\/?[<>]+/)
  end
  must " csv_out_buttom " do
    @page = 1
    @Domain = "weather_location"
    
    assert_equal ["", "form class=\"button_to\" method=\"get\" action=\"/weather_location/csv_out\"",
                  "input type=\"submit\" value=\"CSVダウンロード\" ", "/form"],
      csv_out_buttom( controller: :weather_location).split(/\/?[<>]+/)
  end
  ########### POP UP #########
  must " popupform_buttom_buttom " do
    @page = 1
    @Domain = "weather_location"
    
    assert_equal ["<form action=\"/weather_location/temperatuer\">",
                  "  <input name=\"authenticity_token\" type=\"hidden\" value=\"form_authenticity_token\" />",
                  "  <input name=\"commit\" type=\"submit\"  value=\"temperatuer\"" +
                    " style='margin-top: -12px; left;' ",
                  " onclick=\"window.open('/weather_location/temperatuer', 'new_win'" +
                    ", 'width=500,height=400 '); target='new_win'\">",
                  "<input value=\"weather_location\" type=\"hidden\"" +
                    " name=\"weather_location[controller]\" id=\"weather_location_controller\" />",
                  "</form>"],
      popupform_buttom( :temperatuer,"temperatuer",controller: :weather_location).split(/[\r\n]+/)
  end
  ############# AND ACTION ##########
  must " and_action NoPopUp" do
    @Domain = "weather_location"
    assert_equal "<div><form action=\"/weather/temperatuer?hidden=\" accept-charset=\"UTF-8\" method=\"post\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /><input type='hidden' name='page' value=''><input type=\"submit\" name=\"commit\" value=\"temperatuer\" /><INPUT HTML TAG></form></div>",
      and_action("<INPUT HTML TAG>".html_safe,:temperatuer,"temperatuer",controller: :weather)
  end
  must " and_action With PopUp" do
    @Domain = "weather_location"
    assert_equal "<div><form action=\"/weather/temperatuer?hidden=\" accept-charset=\"UTF-8\" method=\"post\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /><input type='hidden' name='page' value=''><input type=\"submit\" name=\"commit\" value=\"temperatuer\" /><INPUT HTML TAG></form></div>",
      and_action("<INPUT HTML TAG>".html_safe,:temperatuer,"temperatuer",popup: "WIN_NAME",controller: :weather)
  end

end
__END__
  
  must "popupform_buttom" do
    assert_equal ResultWhenNoOption, @ctrl.form_tag( controller: :weather,action: "show")
    #assert_equal ResultWhenNoOption, form_buttom( :show,"label")
  end
  
  must "edit_buttom" do
    pp self.class #controller#.class.inspect
    pp self.controller#.class.inspect
    expect = ResultWhenNoOption.dup
    assert_equal expect,edit_bottom
  end
end
__END__

  must "form_buttom option なし" do
    assert_equal ResultWhenNoOption,  form_buttom( 'index',"label").split(/\/?[<>]+/)
  end
  must "form_buttom option method: :get" do
    expect = ResultWhenNoOption.dup
    expect[1]="form action=\"index\" accept-charset=\"UTF-8\" method=\"get\""
    assert_equal expect,
      form_buttom( 'index',"label",method: :get).split(/\/?[<>]+/)
  end
  must "form_buttom option hideden" do
    expect = ResultWhenNoOption.dup
    expect.insert(3,"input value=\"value\" type=\"hidden\" name=\"[key]\" id=\"_key\" ")
    assert_equal expect,
      form_buttom( 'index',"label",hidden: "key",hidden_value: "value").split(/\/?[<>]+/)
  end
  must "form_buttom option form_notclose" do
    expect = ResultWhenNoOption.dup
    expect.delete_at(-1)
    assert_equal expect,
      form_buttom( 'index',"label",form_notclose: true).split(/\/?[<>]+/)
  end
end

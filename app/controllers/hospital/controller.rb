# -*- coding: utf-8 -*-
class Hospital::Controller < ApplicationController
  before_filter :set_instanse_variable
  attr_accessor :current_busho_id,:month
  def _TableAddEditChangeBusho 
      [[:add_edit_buttoms], ["　　　"],
       [:form,:set_busho,"部署変更",:input_busho]]
  end

  def  _TableEditChangeBusho 
      [[:edit_bottom],      ["　　　"],
       [:form,:set_busho,"部署変更",:input_busho]]
  end

  def set_instanse_variable
    @Links = [
              Menu.new("記号一覧",:kinmucode),
              Menu.new("役割一覧",:role),
              Menu.new("部署登録",:busho), 
              Menu.new("必要人数",:need),
              Menu.new("個人登録",:nurces), 
              Menu.new("役割割当",:role, :action => :show_assign),
              Menu.new("会議登録",:meeting),
              Menu.new("希望入力",:monthly,:action => :hope_regist),
              Menu.new("割付",:monthly,:action => :show_assign),
              Menu.new("様式9",:form9,:action => :index),
              Menu.new("休日",:holyday,:controller => "../holyday",:action => :index,:page=>1,:id => Time.now.year)
             ]
    @month = session[:hospital_year] || Time.now.beginning_of_month
    @current_busho_id = session[:hospital_busho] || 1
    @current_busho    = Hospital::Busho.find(@current_busho_id)
    @current_busho_id_name = @current_busho.name
  end


  def set_busho_month
    @month = session[:hospital_year] = Time.parse(params[@Domain][:month]+"/1 JST").to_date
    @current_busho_id = session[:hospital_busho] = params[@Domain][:current_busho_id].to_i
    redirect_to :action => :index
  end

  def set_busho
    @current_busho_id = session[:hospital_busho] = params[@Domain][:current_busho_id].to_i
    redirect_to :action => :index
  end

end

# -*- coding: utf-8 -*-
require 'html_cell'
class Hospital::Controller < ApplicationController
  include Actions
  before_action :authenticate_user! 
  before_filter :set_instanse_variable
  attr_accessor :current_busho_id,:month
  class BushoGetudo
    attr_accessor :busho_id,:month
    def initialize(arg_busho_id,arg_month)
      set(arg_busho_id,arg_month)
    end
    def set(arg_busho_id,arg_month)
      @busho_id = arg_busho_id
      @month    = arg_month
      self
    end
    def yyyymm ; month.strftime("%Y-%m"); end
  end

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
              Menu.new("記号一覧",:kinmucodes),
              Menu.new("役割一覧",:roles),
              Menu.new("部署登録",:bushos), 
              Menu.new("必要人数",:needs),
              Menu.new("個人登録",:nurces), 
              Menu.new("役割割当",:roles, :action => :show_assign),
              Menu.new("会議登録",:meetings),
              Menu.new("希望入力",:monthly,:action => :hope_regist),
              Menu.new("割付",:monthly,:action => :show_assign),
              Menu.new("様式9",:form9,:action => :index)#,
#              Menu.new("休日",:holyday,:controller => :holydays,:action => :index)
             ]
    @busho_getudo = session[:hospital] ||= 
      BushoGetudo.new(1,Time.now.beginning_of_month.to_date)
    @month = @busho_getudo.month # session[:hospital_year] || Time.now.beginning_of_month
    @current_busho_id = @busho_getudo.busho_id #session[:hospital_busho] || 1
    @current_busho    = Hospital::Busho.find(@current_busho_id)
    @current_busho_id_name = @current_busho.name
  end


  def set_busho_month
    # @month = session[:hospital_year] = Time.parse(params[@Domain][:month]+"/1 JST").to_date
    # @current_busho_id = session[:hospital_busho] = params[@Domain][:current_busho_id].to_i
    session[:hospital] = 
      @busho_getudo.set(params[:busho_getudo][:busho_id].to_i , 
                        Time.parse(params[:busho_getudo][:yyyymm]+"-1").to_date 
                        )
    redirect_to :action => :index
  end

  def set_busho
    # @current_busho_id = session[:hospital_busho] = params[@Domain][:current_busho_id].to_i
    @busho_getudo.busho_id = params[:busho_getudo_busho_id].to_i 
    session[:hospital] = @busho_getudo
    redirect_to :action => :index
  end

end

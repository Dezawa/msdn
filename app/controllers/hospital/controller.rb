# -*- coding: utf-8 -*-
require 'html_cell'
class Hospital::Controller < CommonController #ApplicationController
  include Actions
  before_action :authenticate_user! 
  before_filter :set_instanse_variable
  attr_accessor :current_busho_id,:month
  class BushoGetudo
    attr_accessor :busho_id,:month
    def initialize(arg_busho_id=nil,arg_month=nil)
      set(arg_busho_id,arg_month)
    end
    def set(arg_busho_id,arg_month)
      @busho_id = arg_busho_id || ((busho = Hospital::Busho.first) ? busho.id : nil )
      @month    = arg_month    || Time.now.beginning_of_month.next_month.to_date
      self
    end
    def yyyymm ; month.strftime("%Y-%m"); end
  end

  def _TableAddEditChangeBusho 
    [[:add_edit_buttoms], ["　　　"],
     [:form,:set_busho,"部署変更",:input_busho]
    ]
  end

  def  _TableEditChangeBusho 
    [[:edit_bottom],      ["　　　"],
     [:form,:set_busho,"部署変更",:input_busho]]
  end

  def set_instanse_variable
    @Links = [
              Menu.new("記号一覧",:kinmucodes),
              Menu.new("役割一覧",:roles),
              Menu.new("禁忌",:avoid_combination),
              Menu.new("部署登録",:bushos), 
              Menu.new("必要人数",:needs),
              Menu.new("個人登録",:nurces), 
              Menu.new("役割割当",:roles, :action => :show_assign),
              Menu.new("会議登録",:meetings),
              Menu.new("希望入力",:monthly,:action => :hope_regist),
              Menu.new("割付",:monthly,:action => :show_assign),
              Menu.new("様式9",:form9,:action => :calc),
              Menu.new("休日",:holydays,:controller => "/holydays",:action => :index,:page=>1,:id => Time.now.year)
             ]
    @busho_getudo = YAML.load(session[:hospital] ||= YAML.dump(BushoGetudo.new))
    # @busho_getudo = YAML.load( YAML.dump(BushoGetudo.new))
    @month = @busho_getudo.month 
    if @busho_getudo.busho_id 
      @current_busho_id = @busho_getudo.busho_id #session[:hospital_busho] || 1
      @current_busho    = Hospital::Busho.find(@current_busho_id)
      @current_busho_id_name = @current_busho.name
    end
  end


  def set_busho_sub
    @busho_getudo.busho_id = params[:busho_getudo][:busho_id].to_i 
    session[:hospital] = YAML.dump @busho_getudo
    #logger.debug "session[:hospital]: #{session[:hospital].busho_id}"
  end
  def set_busho_sub
    @busho_getudo.busho_id = params[:busho_getudo][:busho_id].to_i 
    session[:hospital] = YAML.dump @busho_getudo
  end
  def set_busho
    set_busho_sub
    redirect_to :action => :index #show_assign
  end
end

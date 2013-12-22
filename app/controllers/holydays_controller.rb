# -*- coding: utf-8 -*-
require 'html_cell'
class HolydaysController < ApplicationController
  include Actions
  before_action :authenticate_user! 
  before_filter :set_instanse_variable

  Labels = [ HtmlHidden.new(:year),
             HtmlDate.new(  :day  ,"月日",:tform=> "%m/%d",:size => 5),
             HtmlText.new(  :name ,"名称")
           ]
  def set_instanse_variable
    @Model= Holyday
    @TYTLE = "祝祭日・休日"
    @Domain= @Model.name.underscore
    @Edit = true
    @Delete=true
    #@Show  =true
    @SortBy   = :day
    @year = params[:year].to_i if params[:year] 
    @year ||= params[@Domain][:year].to_i if params[@Domain] && params[@Domain][:year]
    @year ||= params[:id].to_i if params[:id] 
    @FindOption = ["year = ?",@year]
    @Findorder = "day" 
    @TableEdit = [ [:input_and_action,:add_on_table,"追加",
                    { :name => @Domain+"[add_no]",:hidden => :year,:hidden_value => @year,:value => 1,:size=>3}],
                   [:form,:edit_on_table,"編集",
                    { :hidden => :year,:hidden_value => @year}],
                   [:form,:years,"年一覧"]]
    @TYTLE_post = "#{@year}年"
    @labels = Labels
  end

  # 
  def years
    @labels=[[HtmlText.new(:year,"年")]]
    @models=Holyday.all.map{|hldy| hldy.year}.uniq
  end

  def show 
    index
  end
  
  def index
    @models = Holyday.all(:conditions => ["year =?",params[:id]],:order => "day")
    @labels = Labels
    render  :file => 'application/index',:layout => 'application' 
  end

  def destroy
    if params[:id] =~ /^year:(\d{4})/
      year = $1
      mm=@Model.all(:conditions => ["year = ?",year]).each{|m| m.destroy }
      redirect_to :action => :years
    else
      model=@Model.find(params[:id])
      year = model.year
      model.destroy 
      redirect_to :action => :index,:id => year
    end
  end

  def new_year
    year = params[:holyday][:new_year].to_i
    unless (@models = Holyday.all(:conditions => ["year = ?",year])).size>0
      @models = Holyday.create_newyear(year)
    end 
    render  :file => 'application/edit_on_table',:layout => 'application'
  end
  def edit_on_table
    year = params[:new_year] ? params[:new_year].to_i : @year
    @TYTLE_post_edit="　#{year}年"
    unless (@models = Holyday.all(:conditions => ["year = ?",year])).size>0
      @models = Holyday.create_newyear(year)
    end 
    @option_tags = [[:hidden_field,@Domain,:year,{:value => year,:name => :year}]]
    render  :file => 'application/edit_on_table',:layout => 'application'
  end
  def update_on_table
    @year = params[@Domain].first[1][:year]
    params[@Domain].each_pair{|id,holyday| 
      holyday[:year]=@year if holyday[:year].blank? && !holyday[:day].blank?
      holyday[:day] = "#{holyday[:year]}/#{holyday[:day]}" 
    }
    @option = {:id => @year}
    super
  end
  def update
     @year = params[@Domain][:year]
    params[@Domain][:day] = "#{@year}/#{params[@Domain][:day]}"
    params[:back_params] = "id,#{@year}"
    params[:back]        = "index"
    super
    
  end

end

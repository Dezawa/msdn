# -*- coding: utf-8 -*-
class ForecastController < CommonController # ApplicationController
  before_filter :set_instanse_variable
  Temp     = %w(temp03 temp06 temp09 temp12 temp15 temp18 temp21 temp24) 
  Weather  = %w(weather03 weather06 weather09 weather12 weather15 weather18 weather21 weather24)
  Humi     = %w(humi03 humi06 humi09 humi12 humi15 humi18 humi21 humi24)
  Vaper    = %w(vaper03 vaper06 vaper09 vaper12 vaper15 vaper18 vaper21 vaper24)
  LabelsMonthList =
    [ HtmlText.new(:location  ,"場所",    :ro => true , :size => 7),
     HtmlLink.new(:month     ,"年月",  :tform => "%Y/%m", :ro => true, :size => 7 ,
                  :link => {  :url => "/forecast",
                            :key => :month, :key_val => :month}),
      HtmlLink.new(:month     ,"グラフ", :ro => true, :size => 7 ,
                  :link => {  :url => "/forecast/graph",:link_label => "グラフ",
                            :key => :month, :key_val => :month}),
    ]
  LabelsDaylies = [
            HtmlText.new(:location ,"場所",    :ro => true , :size => 7),
            HtmlLink.new(:date     ,"月日",  :tform => "%m/%d", :ro => true, :size => 7,
                 :link => {  :url => "/forecast",:key => :date, :key_val => :date}
                        ),
            HtmlLink.new(:date     ,"グラフ", :ro => true, :size => 7 ,
                  :link => {  :url => "/forecast/graph",:link_label => "グラフ",
                            :key => :date, :key_val => :date}),
            HtmlDate.new(:announce ,"最終発表日時",  :tform => "%m/%d %H", :ro => true, :size => 7 ),
            ] +
    Temp.map{  |clm|   HtmlNum.new(clm.to_sym,clm.sub(/temp/,""),:tform => "%.1f") } +
    Vaper.map{ |clm|   HtmlNum.new(clm.to_sym,clm.sub(/vaper/,""),:tform => "%.1f") } +
    Humi.map{  |clm|   HtmlNum.new(clm.to_sym,clm.sub(/humi/,""),:tform => "%.1f") } +
    Weather.map{ |clm| HtmlText.new(clm.to_sym,clm.sub(/weather/,"")) } 
  LabelsDayAll = LabelsDaylies.dup
  LabelsDayAll[1,1] = HtmlDate.new(:date ,"月日",:tform => "%m/%d",:ro => true,:size => 7)
  LabelsDayAll.delete_at(2)  
  def set_instanse_variable
    super
    @Model= Forecast
    @TYTLE = "予報 "
    correction = WeatherLocation.all.map{|wl| [wl.name,wl.location]}
    #Forecast::ZP.map{ |location,value| [value[1],location]}
    @TableEdit = #[[:input_and_action,"get_data","新規取得 年月(日) 2014-7(-10)",{:size=>8}]]
    [ [:select_and_action,:change_location,"地域変更",
       {:correction => correction ,:selected => @weather_location }],
      [:form,:fetch,"取り込み",method: :get] #,[:form,:error_graph,"予報誤差",method: :get]
    ]
    @Domain= @Model.name.underscore
    @TableHeaderDouble = [3,[8,"気温"],[8,"蒸気圧"],[8,"湿度"],[8,"天気"]]
    @FindOption = { :conditions => ["location = ?", @weather_location],
      :order => "date"}
    @FindWhere =  ["location = ?", @weather_location]
    @FindOrder = "date"
  end

  # 予報月の一覧。
  def index
    if params[:month]
      @labels = LabelsDaylies
      @TableHeaderDouble = [4,[8,"気温"],[8,"蒸気圧"],[8,"湿度"],[8,"天気"]]
      daylies_of_month
      render  :file => 'application/index',:layout => 'application'
    elsif params[:date]
      @labels = LabelsDayAll
      daylies_of_a_day
      render  :file => 'application/index',:layout => 'application'
    else
      @TableHeaderDouble = nil
      @labels = LabelsMonthList
      month_list 
    end
  end
  
  def graph
    @graph_format = :jpeg
    if params[:month]
      daylies_of_month
      @graph_path = @Model.graph(@models, @weather_location)
      render  :file => 'application/graph',:layout => 'application'
    elsif params[:date]
      dayly_of_a_day
      @graph_path = @Model.graph(@models, @weather_location)
      render  :file => 'application/graph',:layout => 'application'
    else
      @TableHeaderDouble = nil
      @labels = LabelsMonthList
      month_list 
    end
  end

    def show
    if /[^\d]/ =~ params[:id]
      send(params[:id])
    else
      super
    end
  end

  def change_location
    location = params[@Domain][:change_location]
    @weather_location  = session[:weather_location] = location
    redirect_to "/forecast"
  end

  def error_graph
    location = @weather_location
    @Model.differrence_via_real_graph location , @graph_file  = "forecast-real"
    @graph_format = :jpeg
    render :action => :error_graph,:layout => "hospital_error_disp"
  end

  def fetch
    fore = Forecast.fetch(@weather_location,Time.now.to_date)
    redirect_to "/forecast"
  end

  def new
    location = params[:location] || @weather_location
    fore = Forecast.fetch(location,Time.now.to_date)
    render :text => fore.to_s
  end

  def get_all_location
    locations = WeatherLocation.all.map(&:location)
    locations.each{ |location| Forecast.fetch(location,Time.now.to_date)}
    render :text => locations.join(",")
  end

  def month_list
    @Pagenation = 3
    @page = params[:page] || 1
    @dayly = @Model.order("date desc").group(:month).
      paginate( :page =>  @page,:per_page => @Pagenation)
    @models = @Model.where(:month  => @dayly.map(&:month)).
      where(:location =>  @weather_location).
      group_by{ |dayly| dayly.month }.
      map{|month,daylies| daylies[0]}.reverse
  end

  def daylies_of_month
    @models = @Model.daylies_of_month(@weather_location, params[:month])    
  end
  def daylies_of_a_day
    @models = @Model.daylies_of_a_day(@weather_location, params[:date])
  end
  def dayly_of_a_day
    @models = @Model.dayly_of_a_day(@weather_location, params[:date])
  end
  def index_sub
    @Pagenation = 3
    @page = params[:page] || 1
    @dayly = @Model.order("date desc").group(:month).paginate( :page =>  @page,:per_page => @Pagenation)
    #page_monthes = monthes[(@page-1)*@Pagenation,@Pagenation]
    @models = @Model.where(:month  => @dayly.map(&:month)).
      where(:location =>  @weather_location).
      order("date,announce").
      group_by{ |d| d.date }.
      map{|date,daylies| daylies.sort_by{|d| d.announce}.last}.
      group_by{ |dayly| dayly.month }.map{|m,d| d[0]}
  end

end
__END__
@Model=Forecast
def params
@params ||= {}
end
@weather_location="maebashi"

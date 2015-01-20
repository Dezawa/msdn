# -*- coding: utf-8 -*-
class Sola::DaylyController < Sola::Controller #ApplicationController
  include Actions
  include GraphController
  before_action :authenticate_user!, :only => :load #:except => :load_local_file,
  before_filter :set_instanse_variable
  
  LabelsPeaks =
    [[ HtmlDate.new(:month,"年月",:tform =>"%Y-%m",:ro => true )] ,
     (1..31).map{ |day| 
       HtmlLink.new(:peak_kw,day.to_s,:tform => "%5.2f",
                    :link => {  :url => "/sola/dayly/minute_graph",:key => :id, :key_val => :id})
     }
    ]

     LabelsPowers =
    [[ HtmlDate.new(:month,"年月",:tform =>"%Y-%m",:ro => true )] ,
     (1..31).map{ |day| 
       HtmlLink.new(:kwh_day,day.to_s,:tform => "%5.2f",
                    :link => {  :url => "/sola/dayly/show",:key => :id, :key_val => :id})
     }
    ]
    
  LabelsMonitor =
    [[ HtmlDate.new(:month,"年月",:tform =>"%Y-%m",:ro => true ),
      HtmlLink.new(:month,"編集",:link => {:link_label =>"編",  :url => "/sola/dayly/edit_on_table",
                     :key => :month, :key_val => :month}),
       HtmlNum.new(:total,"月発電量",:tform => "%.0f",:ro => true)
    ],
      (1..31).map{ |day| 
       HtmlNum.new(:kwh_monitor,day.to_s,:tform => "%5.2f",:size => 2)
     }
    ]
    
  LabelsMonthesIndex = 
    [ HtmlDate.new(:month,"年月",:tform =>"%Y-%m"),
      HtmlLink.new(:id,"",
                   :link => {:link_label => "表示", :url => "/sola/dayly/index_month",
                     :key => :month, :key_val => :month}), 
    ]
  OnClick=
    %Q!onClick="window.open('/sola/dayly/minute_graph','graph','width=300,height=300,scrollbars=yes');" target="graph"!
  MLink  = {:url => "/sola/dayly/minute_graph" ,:key => :id,:key_val => :id,:htmloption => OnClick}
  LabelsMonthIndex = 
    [ HtmlDate.new(:date,"年月日",:tform =>"%Y-%m-%d",:ro => true ),
      HtmlNum.new(:peak_kw,"ピーク<br>kW(分)",:tform => "%5.2f"),
      HtmlNum.new(:kwh_day,"発電量<br>kWh(日)",:tform => "%4.1f")
    ] +
    ("04".."20").map{ |kwh| HtmlNum.new("kwh#{kwh}",kwh,:tform => "%4.1f")} +
    [HtmlLink.new(:id,"",:link => { method: "minute_graph", :link_label => "分グラフ"}.merge(MLink))]

  def set_instanse_variable
    super
    @CSVatrs  = @CSVlabels = %w(month)+("01".."31").map{ |day| "kwh#{day}"}

    @Model= Sola::Dayly
    @Domain= @Model.name.underscore
    @TYTLE = "太陽光発電 日データ"
    #@TYTLEpost = "#{@year}年度"
    @TableEdit = [[ :upload_buttom,:load,"TRZファイル取り込み"],
                ]
    @FindOption = {}
    @FindOrder = "date "
    #@Edit = true
    @Delete=true
  end

  def index
    index_sub
    @Labels =LabelsPeaks
    #@models_group_by = find_and.group_by{ |d| d.month }
    @TYTLE_post = "ピーク発電量"
    @TableHeaderDouble = [1,[31,"日々のピーク発電量(kW)"]]
    @method = :peak_kw
    #render  :file => 'application/index',:layout => 'application'    
  end

  def index_monitor
    index_sub
     @Labels =LabelsMonitor # LabelsMonthesIndex
    @TYTLE_post = "モニターデータ 日発電量"
    @TableHeaderDouble = [3,[31,"モニターデータ ：日発電量(kWh)"]]
    @TableEdit = [[:edit_bottom],[:csv_up_buttom,"モニターデータ取り込み"],  [:csv_out,      "CSVダウンロード"],
                 ]
    @method = :kwh_monitor
    render  :action => :index
  end
  def index_day_total
    index_sub
    @Labels =LabelsPowers
    @TYTLE_post = "日 発電量"
    @TableHeaderDouble = [1,[31,"日々の発電量(kWh)"]]

    @method = :kwh_day
    @action = "show"
    render  :action => :index
  end

  def index_month
     month = params[:month]
     @page = params[:page] || 1 
     @TableHeaderDouble = [3,[19,"毎時発電量(kWh)"]]
     @TableEdit = [[ :upload_buttom,:load,"TRZファイル取り込み"]]
     @labels = LabelsMonthIndex
     @Show = true
     #@models = @Model.where(month: month)
     @FindWhere = {month: month}
     find_and
     render  :file => 'application/index',:layout => 'application'
  end

  def edit_on_table
    month = params[:month]
    @Labels =[LabelsMonitor[0][0,1], LabelsMonitor[1]]
    @models = @Model.where(month: month).order(:date).to_a
    @TYTLE_post = "モニターデータ 日発電量"
    @TableHeaderDouble = [1,[31,"モニターデータ ：日発電量(kWh)"]]
    @TableEdit = [[:update_bottom]]
    @method = :kwh_monitor
    @action = "show"
  end
  def update_on_table 
    @models = [] 
    @errors = []
    @result = true
    @modelList = params[@Domain]
    @modelList.each_pair{|i,model| id=i.to_i
        @mdl = @Model.find(id)
        @result &=  @mdl.update_attributes(model)
        @errors << @mdl.errors if @mdl.errors.size>0
        @models << @mdl
    }
    redirect_to :action => :index_monitor 
  end

  def load
    logger.debug("Sola::DaylyCnrl load #{params[@Domain][:uploadfile]}")
    @Model.load_trz params[@Domain][:uploadfile]
    redirect_to :action => :index
  end
  def load_local_file
    @Model.load_trz params[:uploadfile]
    redirect_to :action => :index
  end

  def csv_out
    filename ||= @CSVfile || (current_user.username+@Model.name.underscore.gsub(/\//,"_")+".csv")
    tmpfile = @Model.csv_out_monitor(filename,@CSVatrs, @CSVlabels)
    send_file(tmpfile,:filename =>  filename)
  end

  def csv_upload
    errors= @Model.csv_update_monitor(params[:csvfile]||params[@Domain][:csvfile], @CSVlabels,@CSVatrs)
    unless errors[0]
      flash[:message] = errors[1]
      redirect_to :action => :index_monitor
    else
      @Model.send(@Refresh,true) if @Refresh
      flash[:message] = errors[1] if  errors[1]>""
      redirect_to :action => :index_monitor
    end
  end

  def show
    @model = @Model.find params[:id]
  end
  def show_graph
    Sola::Monthly.monthly_graph_with_peak(@graph_file_monthly = "sola_monthly_with_peak")
    Sola::Monthly.dayly_graph_with_peak(@graph_file_dayly = "sola_dayly_with_peak")
    @TYTLE_post = "　累積発電量とピーク発電量"
    @postTitleMsg = "
        発電量はソーラパネルメーカ提供oコントローラの日間発電量による。(手動転記なのでupdate遅れる事あり)<br>
        ピーク発電量は自前電力計による1分間平均発電量。<p>
　　　　電池残量:%d　　 電波強度 %d
" 
    status =  Status::TandD.where(base_name: "dezawa",group_name: "Dhome", group_remote_name: "power01" ).order("group_remote_ch_unix_time desc").first

    @postTitleMsg = @postTitleMsg%[:group_remote_ch_current_batt,:group_remote_rssi].
      map{ |sym| status[sym]}
  end

  def correlation
    @graph_file = "sola_correlation"
    @graph_file_dir = Rails.root+"tmp" + "img"
    @Model.correlation_graph(@graph_file,@graph_file_dir)
    render   :file => 'application/graph', :layout => "simple"
  end

  def peak_graph
    @graph_file = "sola_peak"
    @graph_file_dir = Rails.root+"tmp" + "img"
    Sola::Dayly.peak_graph(@graph_file,@graph_file_dir)
    render   :file => 'application/graph', :layout => "simple"
  end

  def minute_graph
    id = params[:id].to_i
    @model = @Model.find id
    @TableEdit = nil
    @TYTLEpost = @model.date.strftime("%Y-%m-%d")
    @graph_file = "sola_minute"
    @graph_file_dir = Rails.root+"tmp" + "img"
    @model.minute_graph(@graph_file,@graph_file_dir)
    render   :file => 'application/graph', :layout => "simple"
  end

  private
  def index_sub
    @Pagenation = 12
    @page = params[:page] || 1
    @dayly = @Model.order("date desc").group(:month).paginate( :page =>  @page,:per_page => @Pagenation)
    #page_monthes = monthes[(@page-1)*@Pagenation,@Pagenation]
    @models_group_by = @Model.where(:month  => @dayly.map(&:month)).order("date").group_by{ |d| d.month }
  end


end

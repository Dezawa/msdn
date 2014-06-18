# -*- coding: utf-8 -*-
class Shimada::MonthController <  Shimada::Controller
  Labels = 
    [ HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
      HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month",
                     :key => :id , :key_val => :id, :link_label => "グラフ"})
    ]
  PowerLabels =
    [ HtmlCeckForSelect.new(:id,""),
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%m/%d")
    ] + 
      Shimada::Power::Hours.map{ |h| 
        HtmlNum.new( h.to_sym,h.sub(/hour0?/,""),:tform => "%.0f",:size => 3)
      }
  def set_instanse_variable
    super
    @Model= Shimada::Month
    @TYTLE = "シマダ:月度データ"
    @labels=Labels
    @AssosiationLabels = PowerLabels
    @TableEdit  = [:csv_up_buttom]
    @Show = true
    # @Delete = @configure
    # @conditions = { :order => "bunrui,kamoku" }
    @Domain= @Model.name.underscore
    # @Refresh = :kamokus
    @SortBy    = :month
    #@CSVatrs = CSVatrs; @CSVlabels = CSVlabels
  end

  def show ;
    @models = @Model.find(params[:id]).powers
    @Show = @Edit = @Delete = nil
    @Graph = true
    @TYTLE_post = @models.first.date.strftime("(%Y年%m月)")
    @TableEdit  =  [[:form,:index,"一覧に戻る"],
                    [:form,:graph_month,"月度グラフ",{ :hidden => :id,:hidden_value => params[:id]} ],
                    [:form,:graph_selected,"選択日グラフ",{ :form_close => false}]
                   ]
    @labels = PowerLabels
    @TableHeaderDouble = [2,[24,"時刻"]]
  end

  def graph
    @power = [Shimada::Power.find(params[:id])]
    Shimada::Power.gnuplot(@power)
    @TYTLE = "消費電力推移" + @power.first.date.strftime("(%Y年%m月%d日)")
  end

  def show_gif
    send_file RAILS_ROOT+"/tmp/shimada/power.gif", :type => 'image/gif', :disposition => 'inline'
  end


  def graph_month
    id = params[@Domain] ? params[@Domain][:id] : params[:id] 
    @power = @Model.find(ids).powers
    graph_mult(@power)
  end

  def graph_selected
    ids = params[:check_id].
      delete_if {|key, value| value == "0" }.keys.map(&:to_i)
    @power=Shimada::Power.find(ids)  
    graph_mult(@power) 
  end

  def graph_mult(power)
    Shimada::Power.gnuplot(power)
    @TYTLE = "消費電力推移" + @power.first.date.strftime("(%Y年%m月)")
    render :action => :graph
  end

  def csv_upload
    errors= @Model.csv_upload(params[@Domain][:csvfile])
    redirect_to :action => :index
  end
end

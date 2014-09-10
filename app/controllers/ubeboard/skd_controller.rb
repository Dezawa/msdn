# -*- coding: utf-8 -*-
require 'tempfile'
#
class Ubeboard::SkdController < CommonController #ApplicationController
  include Actions
  before_action :authenticate_user! 
  #before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  skip_before_filter :verify_authenticity_token
  
  delegate :logger, :to=>"ActiveRecord::Base"

  EditOnly = {
    true => "実績入力・追加・削除" ,
    nil => "データ更新&立案実行"   ,
    false => "データ更新&立案実行"
  }

  Commit    = {true => "更新" , nil => "データ更新&立案実行", false =>"データ更新&立案実行"}
  Action    = {true => :edit_only , nil => :edit , false => :edit }
  Labels = [HtmlText.new( :id                , "立案No", :align => :right, :ro=>true),
            HtmlDate.new( :skd_from          ,  "立案期間開始日",:tform=>"%Y-%m-%d"),
            HtmlDate.new( :skd_to            ,  "立案期間終了日",:tform=>"%Y-%m-%d"),
            HtmlText.new( :runtime_shozo_w   ,  "抄造西稼働時間/時間"),
            HtmlText.new( :runtime_shozo_e   ,  "抄造東稼働時間/時間"),
            HtmlText.new( :runtime_dry_o     ,  "原乾燥稼働時間/時間"),
            HtmlText.new( :runtime_dry_n     ,  "新乾燥稼働時間/時間"),
            HtmlText.new( :runtime_kakou     ,  "加工  稼働時間/時間"),
            HtmlText.new( :plantime_shozo_w  ,  "抄造西予定時間/時間"),
            HtmlText.new( :plantime_shozo_e  ,  "抄造東予定時間/時間"),
            HtmlText.new( :plantime_dry_o    ,  "原乾燥予定時間/時間"),
            HtmlText.new( :plantime_dry_n    ,  "新乾燥予定時間/時間"),
            HtmlText.new( :plantime_kakou    ,  "加工予定時間/時間")
           ]
  Labels2= [
            ["時間/分","抄造西","抄造東","原乾燥","新乾燥","加工","　"],
            ["稼働",:runtime_shozo_w,:runtime_shozo_e,:runtime_dry_o,
             :runtime_dry_n,:runtime_kakou,"立案期間から休日を除いたもの"],
            ["予定実働",:plantime_shozo_w,:plantime_shozo_e,:plantime_dry_o,
             :plantime_dry_n,:plantime_kakou,"製造に割り当てられた時間"],
            ["保守",:mainttime_shozo_w,:mainttime_shozo_e,:mainttime_dry_o,
             :mainttime_dry_n,:mainttime_kakou,"切り替えは除く"],
            ["切り替え",:changetime_shozo_w,:changetime_shozo_e,:changetime_dry_o,
             :changetime_dry_n,:changetime_kakou,"名前付き、名前なしを含む"],
            ["非割り当て",:freetime_shozo_w,:freetime_shozo_e,:freetime_dry_o,
             :freetime_dry_n,:freetime_kakou,"　"],
            ["実績",:donetime_shozo_w,:donetime_shozo_e,:donetime_dry_o,
             :donetime_dry_n,:donetime_kakou,"　"]
           ]

  RunTimeLabels = [
                   ["　","先月末累積","今月末累積","上限","設定Max"],
                   ["西抄造 抄造時間",:runned_pf_shozow,:running_pf_shozow,:limit_pf_shozow,1000],
                   ["東抄造 抄造時間",:runned_pf_shozoe,:running_pf_shozoe,:limit_pf_shozoe,1000],
                   ["西抄造 抄造枚数",:runned_wf_shozow,:running_wf_shozow,:limit_wf_shozow,"180,000-200,000"],
                   ["東抄造 抄造枚数",:runned_wf_shozoe,:running_wf_shozoe,:limit_wf_shozoe,"180,000-200,000"],
                   ["原乾燥 乾燥枚数",:runned_dryo   ,:running_dryo   ],
                   ["新乾燥 乾燥枚数",:runned_dryn   ,:running_dryn   ]
                  ]
  RunTimeSyms = [:runned_wf_shozow,:runned_wf_shozoe,:limit_wf_shozow,:limit_wf_shozoe,:runned_dryo,:runned_dryn]
                 

  #          item              label   help type width
  planLabels0 = [#HtmlText.new(:ube_skd_id          ,"立案No",:ro],
                 HtmlText.new(:id                ,"ID",:align=>:right, :ro=>true,:size => 2),
                 HtmlText.new(:jun               ,"優先順",:align=>:right,:size => 2),
                 HtmlText.new(:lot_no            ,"製造番号",:size => 5),
                 HtmlText.new(:mass              ,"製造数",:align=>:right,:size => 3),
                 HtmlProname.new ,
                 HtmlMeigara.new(:include_blank=>true),
                 HtmlText.new(:yojoko            ,"養生庫",:align=>:right,:ro=>true), 
                ]
  planLabels1 = [
                 HtmlPlanTime.new(:plan_shozo_from   ,"予定抄造開始"),
                 HtmlPlanTime.new(:plan_shozo_to     ,"予定抄造終了"),
                 HtmlPlanTime.new(:plan_yojo_from    ,"予定養生開始"),
                 HtmlPlanTime.new(:plan_yojo_to      ,"予定養生終了"),
                 HtmlPlanTime.new(:plan_dry_from     ,"予定乾燥開始"),
                 HtmlPlanTime.new(:plan_dry_to       ,"予定乾燥終了"),
                 HtmlPlanTime.new(:plan_kakou_from   ,"予定加工開始"),
                 HtmlPlanTime.new(:plan_kakou_to     ,"予定加工終了"),
                 HtmlText.new(:lot_no            ,"製造番号",:size => 5),
                 HtmlResultTime.new(:result_shozo_from ,"実績抄造開始"),
                 HtmlResultTime.new(:result_shozo_to   ,"実績抄造終了"),
                 HtmlResultTime.new(:result_yojo_from  ,"実績養生開始"),
                 HtmlResultTime.new(:result_yojo_to    ,"実績養生終了"),
                 HtmlResultTime.new(:result_dry_from   ,"実績乾燥開始"),
                 HtmlResultTime.new(:result_dry_to     ,"実績乾燥終了"),
                 HtmlResultTime.new(:result_kakou_from ,"実績加工開始"),
                 HtmlResultTime.new(:result_kakou_to   ,"実績加工終了")
                ]

  PlanLabelsD =    planLabels0 + planLabels1
  PlanLabelsE =    [HtmlCheck.new(:delete ,"削除")] +
    planLabels0 + [HtmlCheck.new(:copy ,"実績コピー"  )] + planLabels1
  SkdToLabels   = HtmlDate.new( :skd_to,@label=>"",:tform => "%Y/%m/%d",:size=>7)
  SkdFromLabels = HtmlDate.new( :skd_from,@label=>"",:tform => "%Y/%m/%d",:size=>7)
  Sort = { 
    'jun' => '優先順ソート', 
    'lot' => '製造番号順ソート',
    'shozo'=> '抄造時間順ソート',
    'dry'=> '乾燥時間順ソート',
    'kakou'=> '加工時間順ソート'
  }
  Sort_key = %w(jun lot shozo dry kakou)

  # LiPS CSVファイルを読み込み、Ubeboard::Planを作る
  # LiPS_load_subにて表示する
  def lips_load
   @plans,@error = Ubeboard::Plan.make_plans_from_lips(params[:csvfile])
    @skd_from_label = SkdFromLabels
    @skd_to_label   = SkdToLabels
   lips_load_sub
  end

  # 新規立案準備画面を出す
  def lips_load_sub(plans=nil)
    @plans = plans if plans
    @sort = Sort_key - ['jun']
    @Sort  = Sort
    @labels = Labels2
    @RunTimeLabels=RunTimeLabels
    @plabels= PlanLabelsE
    @model = Ubeboard::Skd.new
    @model.ube_plans << @plans

    # 時々起きる、ube_product 無しのplanができてしまうことの後処理。削除
    Ubeboard::Plan.delete_all("ube_product_id is null")

    #@plans = @model.ube_plans
    if @model.save
      @error.each{|error| @model.errors.add(:base,error)}
      #@plans.sort{|p| p.id}.each{|plan| plan.save}
      @plans.each{|plan| plan.save}
      render :action => :edit
    else
       @error.each{|error| @model.errors.add(:base,error)}
      render :action => :new 
    end

  end

  # 
  def csv_out
    params[:doc_from] = "2000/13/40" if params[:doc_from]==""
    begin 
      from = Time.parse(params[:doc_from])
      to   = from + ((params[:doc_to].to_i rescue 8) - 1).day
      id = params[:id]
      # doc_to: 6/17 doc_from: 6/10  id: "96"
      @model = Ubeboard::Skd.find(id)#,:include =>  {:ube_plans => :ube_product})
      
      # ZIP file を作り、
      csv_file = Tempfile.new("csvfile","#{Rails.root}/public/tmp")
      csvfile,mode = @model.csv_out(from,to,csv_file)
      filename = current_user.login + tytle + ".zip"
      send_file(csvfile.path, :filename =>filename)
    
    rescue
      re_disp(params)
    end
    
  end

  def re_disp(params)

      case params[:show_edit]
      when "e" ;      
        @TYTLE = "製造計画修正立案"
        @sortkey = (params[:sort] || 'jun' )
        @edit_only = nil
        edit_sub(params)
      when "eo"
        @TYTLE = "製造計画 実績入力・追加・削除"
        @sortkey = (params[:sort] || 'jun' )
        @edit_only = true
        edit_sub(params)
      else     ;      show_sub(params)   
      end
  end

  #製造指示書PDFの出力
  def doc_out
      id = params[:id]
      @model = Ubeboard::Skd.find(id)#,:include =>  {:ube_plans => :ube_product})
      from = (params[:doc_from].blank? ? @model.skd_from : Time.parse(params[:doc_from])) rescue @model.skd_from
      from -= (from.year - @model.skd_from.year).year
      to   = from + ((params[:doc_to].to_i rescue 8) - 1).day
      doc_out_sub(id,"製造指示書",from,to,true)
       
  end

  #月度計画PDFの出力
  def doc_out_all
    #render :action => "test" ;return
    from = to = nil
    id = params[:id]
    @model = Ubeboard::Skd.find(id)#,:include =>  {:ube_plans => :ube_product})
    doc_out_sub(id,"月度計画",from,to)
  end

  #月度計画もしくは製造指示書のPDFを出力する
  #- 期間がnilだと月度計画になる。
  def doc_out_sub(id,tytle,from,to,weekly=false)
    # doc_to: 6/17 doc_from: 6/10  id: "96"
 
   # PS file を作り、
    pdf_file = Tempfile.new("pdffile","#{Rails.root}/public/tmp")
    pdffile,mode = @model.doc_out(from,to,pdf_file,weekly)
    filename = current_user.login + tytle + ".pdf"
    send_file(pdffile.path, :filename =>filename)
  end

  def csv_download  #:nodoc:
    @model = Ubeboard::Skd.find( params[:id])# ,:include => {:ube_plans => :ube_product})
    csv = @model.csvout
    csvfile=Tempfile.open("schedule","#{Rails.root}/public/tmp")
    csvfile.print csv 
    csvfile.close
    filename = current_user.login + "月度計画データ.csv"
    send_file(csvfile.path, :filename =>filename)

  end

  def index  #:nodoc:
    @labels = Labels
    @models = Ubeboard::Skd.all#(:include => :ube_plans )#=> :ube_product})
    #render :action => "test"
  end

  def new  #:nodoc:
    @TYTLE = "新規製造計画立案"
    @labels = Labels2
    @RunTimeLabels=RunTimeLabels
    @plabels= PlanLabelsE
    @model = Ubeboard::Skd.new
    @plans = []
    @skd_from_label = SkdFromLabels
    @skd_to_label   = SkdToLabels
  end

  def edit  #:nodoc:
    @TYTLE = "製造計画修正立案"
    @sortkey = (params[:sort] || 'jun' )
    @edit_only = nil
    edit_sub(params)
  end

  def edit_only  #:nodoc:
    @TYTLE = "製造計画 実績入力・追加・削除"
    @sortkey = (params[:sort] || 'jun' )
    @edit_only = true
    edit_sub(params)
  end

  def sort_edit  #:nodoc:
    @sortkey = (params[:sort] || 'jun' )
     edit_sub(params)
  end


  def edit_sub(params)  #:nodoc:
    @labels = Labels2
    @RunTimeLabels=RunTimeLabels
    @plabels= PlanLabelsE
    @EditOnly = EditOnly
    @model = Ubeboard::Skd.find( params[:id])#,:include => {:ube_plans => :ube_product})[0]
    #@model  = Ubeboard::Skd.where(id: 1).joins(:ube_plans)#,:include => {:ube_plans => :ube_product})[0]
    @model.set_replan_from(params[:ube_skd] ? params[:ube_skd][:replan_from] : nil)
      #(Time.parse(params[:ube_skd][:replan_from]) ||  @model.skd_from) if params[:ube_skd]
    @model.error_check
    #@sortkey = (params[:sort] || 'jun' )
    plan_sort(@sortkey)
    #logger.debug("Ubeboard::SkdCont#edit_sub: @sortkey=#{@sortkey}")
    render :action => :edit
  end

  def show_sub(params)  #:nodoc:
    @model = Ubeboard::Skd.find(params[:id])#,:include => :ube_plans)[0]
    @sortkey = (params[:sort] || 'jun' )
    #@model.set_replan_from(params[:ube_skd][:replan_from])# = Time.parse(params[:ube_skd][:replan_from]) ||  @model.skd_from
    show_view
  end

  def show_view  #:nodoc:
    @TYTLE = "製造計画"
    @labels = Labels2
    @RunTimeLabels=RunTimeLabels
    @plabels= PlanLabelsD
    @model.error_check
    plan_sort(@sortkey)
    render :action => :show
  end

  #苦肉の策
  #  Ubeboad/top の アクションボタンからの /ube_skd/lipd_load は期待通り #lips_load を呼ぶが
  #  Lips/calc からの 参照での /ube_skd/lips_load は id="lips_load" への #show を呼ぶ
  #  route.rb にて map.resources :ube_skd をなくせば期待通りとなるが、ube_skd_??? が無くなる
  #  ため、view にていろいろ不具合が起こり、解決困難なものも発生した。
  def show
    if params["id"] == "lips_load" ;

      @plans,@error = Ubeboard::Plan.make_plans_from_lips(params[:csvfile])
      lips_load_sub
      return
    end
    show_sub(params)
  end

  def sort
    show_sub(params)
  end

  def create
    sort = (params[:sort] || 'jun' )
    @sort = Sort_key - [sort]
    @Sort  = Sort
    @TYTLE = "新規製造計画立案"
    @labels = Labels2
    @RunTimeLabels=RunTimeLabels
    @plabels= PlanLabelsE

    # skd_from,skd_toに年号がないとエラーとなる
    [:skd_from,:skd_to].each{|skd_time| 
      if timestr = params[:ube_skd][skd_time]
        params[:ube_skd][skd_time] = Time.parse(timestr.gsub(/[^\d]+/,"/")).strftime("%Y/%m/%d")
      end
    }
    ube_skd = params.require(:ube_skd).permit(attr_list(Labels))#[:ube_skd]
    @model = Ubeboard::Skd.new( ube_skd )
    if ! params[:excelfile].blank?
      product_plan_to_ubeplan=Function::ProductPlanToUbePlan.new(params[:excelfile])
      plans = product_plan_to_ubeplan.make_ube_plans
      errors = product_plan_to_ubeplan.errors.uniq
    elsif ! params[:csvfile].blank?
      plans,errors = Ubeboard::Plan.make_plans_from_lips(params[:csvfile])
    elsif params[:ube_plan] #&& params[:ube_plan].size>0
      plans,errors = Ubeboard::Plan.make_plans_from_params(params[:ube_plan])
    else
      plans,errors = [[],["CSVファイルが指定されて居ません"]]
    end

    sort = (params[:sort] || 'jun' )
    @model.replan_from = @model.skd_from
    if @model.save && plans.size > 0
      errors.each{|error| @model.errors.add(:base,error)}
      stock =  @model.stock 
      @plans = (stock + plans).compact
      #@plans.each{|plan| @model.ube_plans << plan}  
      @model.ube_plans << @plans
      #d,s,n=@model.sorted_plan
      #logger.info("DBG done=#{d.map(&:id).join(' ')} stock=#{s.map(&:id).join(' ')}")
      @plans.each{|plan| plan.save}
      plan_sort(sort)
      render :action => :edit
    else
      errors.each{|error| @model.errors.add(:base,error)}
      @plans = plans
      @model.ube_plans << @plans  
      plan_sort(sort)
    @skd_from_label = SkdFromLabels
    @skd_to_label   = SkdToLabels
      render :action => :new
    end
  end

  
  def makeplan
    @labels = Labels2
    @RunTimeLabels=RunTimeLabels
    @plabels= PlanLabelsE
    @model = Ubeboard::Skd.find(params[:id])#,:include => :ube_plans)#{:ube_plans => :ube_product})
    @model.jun_only = (params[:ube_skd][:jun_only]=="1")
    @model.set_replan_from(params[:ube_skd] ? params[:ube_skd][:replan_from] : nil)# = Time.parse(params[:ube_skd][:replan_from]) ||  @model.skd_from
    @model.make_plan(:jun_only => (params[:ube_skd][:jun_only]=="1"))
    @model.save
    @model.after_find2
    @model.ube_plans.each{|plan| plan.save}
    @sortkey = (params[:sort] || 'jun' )
    #@model.error_check
    plan_sort(@sortkey)
    render :action => :edit #redirect_to :action=>:edit,:id=>params[:id] 
  end

  def update
    @edit_only = (params[:commit] == Commit[true])
    [:skd_from,:skd_to].each{|skd_time| 
      if timestr = params[:ube_skd][skd_time]
        params[:ube_skd][skd_time] = Time.parse(timestr.gsub(/[^\d]+/,"/")).strftime("%Y/%m/%d")
      end
    }
    ube_skd =  params.require(:ube_skd).permit(attr_list(Labels))

    RunTimeSyms.each{|sym| ube_skd[sym].gsub!(/,/,"") unless ube_skd[sym].blank?}
    skd=Ubeboard::Skd.find(params[:id])
    skd.set_replan_from(params[:ube_skd][:replan_from])
    ube_skd[:replan_from] = skd.replan_from
    skd.update_attributes(ube_skd)
    plans = params[:ube_plan]
    plans.each{|id,plan| 
      next unless ube_plan = Ubeboard::Plan.find(id) rescue nil
      if plan.delete(:delete) == "1" && ube_plan.deletable?
        ube_plan.destroy
        next
      end

      # 実績のフォーム、年月の補正。作業の当年当月になってしまうのを防ぐ。
      Ubeboard::Skd::Reuslts.each{|time| next if plan[time].blank? 
        plan[time] = Time.parse(plan[time]) 
        # skd_from と比べ、2月以上離れていたら年が違うと判断する。
        # それを四捨五入で済ませる
        #                当年当月が　期間開始より　　　　　　　　　　半年以上未来だったら
        # plan[time] -= ((plan[time]-params[:ube_skd][:skd_from])/1.year).round.year
        plan[time] -= ((plan[time]-skd.skd_from)/1.year).round.year

      }
      copy = plan.delete(:copy)
      #logger.debug("COPY0 #{plan[:lot_no]} is #{copy}")
     ube_plan.update_attributes(plan)
      if copy =="1"
        #logger.debug("COPY1 #{ube_plan.lot_no} #{ube_plan.result_dry_to}")
        ube_plan.copy_results && ube_plan.save
        #logger.debug("COPY2 #{ube_plan.lot_no} #{ube_plan.result_dry_to}")
      end
    }
    @model = Ubeboard::Skd.find(params[:id])#,:include => :ube_plans)
    if   @model.update_attributes(params.require(:ube_skd).permit(attr_list(Labels)))
      @model.ube_plans.each{|plan| plan.save}

      @TYTLE = "製造計画修正"
      @labels = Labels2
      @RunTimeLabels=RunTimeLabels
      @plabels= PlanLabelsE
      @model = Ubeboard::Skd.find(params[:id])#,:include => :ube_plans)
      unless @edit_only
        @model.jun_only = (params[:ube_skd][:jun_only]=="1") 
        @model.make_plan(:jun_only => (params[:ube_skd][:jun_only]=="1"))
        @model.save
        @model.ube_plans.each{|plan| plan.save}
      end
      #redirect_to :action=>:edit,:id=>params[:id]
     @sortkey = (params[:sort] || 'jun' )
    plan_sort(@sortkey)
    #logger.debug("Ubeboard::SkdCont#edit_sub: @sortkey=#{@sortkey}")
      @model.error_check
    render :action => :edit
     #edit_sub(params)
    else
    @sortkey = (params[:sort] || 'jun' )
    plan_sort(@sortkey)
    #logger.debug("Ubeboard::SkdCont#update_false: @sortkey=#{@sortkey}")
      render :action=>:edit
    end

  end

  def destroy
    @model = Ubeboard::Skd.find(params[:id])
    @model.ube_plans.clear
    @model.destroy

    respond_to do |format|
      format.html { redirect_to :action => :index }
      format.xml  { head :ok }
    end

  end

  def input_result
    @id = params[:id]
    @model = Ubeboard::Skd.find(@id,:select => "id,skd_from,skd_to")
  end

  def update_result
    @model = Ubeboard::Skd.find(params[:ube_skd][:id])
    @model.result_update(params[:ube_skd])
    show_view
  end

   def plan_sort(sort)
    @plans = @model.ube_plans.sort{|a,b| 
      case sort
      when 'jun'
        case [!!a.jun,!!b.jun]
        when [true,true] ; a.jun <=> b.jun
        when [true,false]; -1 
        when [false,true]; 1
        else ; 0 #a.id<=> b.id
        end
      when 'dry'
        (a.dry?.to_s  <=> b.dry?.to_s )*64 + 
          (a.plan_dry_from.nil? ? (b.plan_dry_from.nil? ? 0 : 32) : (b.plan_dry_from.nil? ?  -32 : 0)) + 
          (a.plan_dry_from.to_i   <=>  b.plan_dry_from.to_i) * 16 
      when 'shozo'
        (a.shozo?.to_s  <=> b.shozo?.to_s )*64 + 
          (a.plan_shozo_from.nil? ? (b.plan_shozo_from.nil? ? 0 : 32) : (b.plan_shozo_from.nil? ? -32:0)) + 
          (a.plan_shozo_from.to_i   <=>  b.plan_shozo_from.to_i) * 16 +
          (a.plan_dry_from.to_i   <=>  b.plan_dry_from.to_i) * 4 +
          (a.plan_kakou_from.to_i   <=>  b.plan_kakou_from.to_i) * 1
      when 'kakou'
          (a.plan_kakou_from.nil? ? (b.plan_kakou_from.nil? ? 0 : 32) : (b.plan_kakou_from.nil? ? -32:0))+
         (a.plan_kakou_from.to_i   <=>  b.plan_kakou_from.to_i)*16+
          (a.plan_shozo_from.nil? ? (b.plan_shozo_from.nil? ? 0 : 8 ) : (b.plan_shozo_from.nil? ? -8 : 0 )) + 
          (a.plan_shozo_from.to_i   <=>  b.plan_shozo_from.to_i) 
      when 'lot'
         (a.lot_no   <=>  b.lot_no)

      else
        (a.plan_shozo_from.nil? ? (b.plan_shozo_from.nil? ? 0 : 32 ) : (b.plan_shozo_from.nil? ? -32:0))+
        (a.plan_shozo_from.to_i   <=>  b.plan_shozo_from.to_i)
      end
    }
    @sort = Sort_key - [sort]
    @Sort  = Sort
  end

  def test
    render :text => "TEST#{params[:pro_id]}"
  end

protected
  def set_filename
    user = current_user.login
    @filebase ="#{user}-#{session.id.to_s(32)}" 
    @pdffile = "/tmp/#{@filebase}"
    @prefix = "#{Rails.root}/public"
  end

end
#end
class Nil
def to_i ;  0.0 ;end
end
#class Ubeboard::SkdController < ApplicationCon<troller

__END__
$Id: ube_skd_controller.rb,v 2.39 2012-10-28 03:25:32 dezawa Exp $

# -*- coding: utf-8 -*-
# --
#  Filters added to this controller apply to all controllers in the application.
#  Likewise, all the methods added will be available for all controllers.
# ++
require 'html_cell'

# アクセス権管理のための権限フラグ @configure,@editor,@permitの設定と
# 基本的なコントローラーのmethodを定義する。
#  <b>定義されるmethod<b>
#  index,new,create,edit,update,destroy,edit_on_table,update_on_table,add_on_table
#  csv_out,csv_upload,find,pagenate
# 
# コントローラーのModel毎の違いを解決するために、次の利用手順をとる。
# 1. before_filter :set_instanse_variable を設定する
# 2. set_instanse_variable では次のインスタンス定数を定義する
# @Model :: 必須||モデル名 　　例：UbeOperation
# @TYTLE :: 必須||画面のタイトル。これに"一覧"、"編集" などが追記される。例 工程速度
# @TYTLEpost :: || タイトルの後の「一覧」などの後に追加される。例　"#{@year.year}年度"
# @labels :: 必須||一覧表や編集画面で使われる項目とその属性の一覧。例　@labels=Labels
# @Links :: 　　||画面タイトルの上に、関連先へのリンクが表示される。
#        ::     ||  内容 ［［"ラベル",controller,action],［],,,]
# @FindOption :: 　||一覧や**_on_tabble にて Modelから検索する時の、findのoption
#             ::  ||　:order,:conditions などを定義する。
# @errors :: 　　||一覧表に表示すべきエラーメッセージを返すProc
#         ::  　　||例 Proc.new{@Model.error_check.join("<br>")}
# @TableEdit :: 　||一覧表での編集、追加を行うときにtrueにする
#            :: 　 ||　true　： 標準の［追加]［1]　［編集] を表示する
#            :: 　 ||　String： 文字列をそのまま html として書き出す
#            :: 　 ||　Array ： ApplicationHelper#action_buttoms で書き出す
# @Edit,@Delete,@Show :: 　　||trueのとき一覧表の各行に 編集、削除、表示 へのリンクを表示する。
#                     ::  　 ||　現時点では @Showは未対応
# @Domain :: 必須||入力エリアなどの name= のドメイン部分に使われる。推奨：@Model.name.underscore
# @Refresh :: 　　||選択肢として使われるModelで、予めその一覧を用意してあるとき、
#          ::  　 ||　update、delete、update_on_table、csv_uploadなどの後でリフレッシュする
#          ::  　 ||　そのリフレッシュを行うMethod(のSymbol)を定義する。例 @Refresh = :kamokus
# @SortBy :: 　　||update_on_tableの後で、一覧に出すためにソートが必要がModelがある。
#         ::  　 ||　その場合にソートに用いるsymbolを定義する。例　@SortBy = :bunrui
#         ::  　 ||　@models.sort!{|a,b| a[@SortBy]<=>b[@SortBy]} if @SortBy として使われる
# @CSVatrs,@CSVlabels :: 　　||csv_out,csv_uploadの時のカラム名など。Function::CsvIOを参照。
# @CSVfile :: 　　||csv_outの時のファイル名の後半。login名＋@CSVfile として使われる。
#          ::  　 ||　無い場合は、モデル名のアンダースコア化が使われる。
# @Pagenation :: 　　||ページ送りをする場合、1頁当たりの行数を定義する。
# @New :: 　　||new するときに、初期値として入れて置きたい情報を定義するHash
#      ::  　　||　例　@New = {:no => no, :date => Time.now}
# @Create :: 　　||新規作成時に強制的に入れる値を定義するHash。
#          :: 　 ||　例 @Create = {:owner => current_user.login }
# @PostMessage :: 　　||newの画面に注意などを記述する場合、その html文を定義する。
module Actions

  # Uncomment this to filter the contents of submitted sensitive data parameters

  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  #
  # アクセス管理に用いる権限フラグの設定を行う
  # [@configure] システムの状態を変える権限をイメージする。サーバ、システム管理者。
  #              ユーザには公開していないDBの編集や、ユーザには与えない編集権。
  # [@editor] ユーザのうち、一番強い権限。データを変更できる権限をイメージ
  # [@permit] ユーザのうち、弱い権限。参照のみの権限をイメージ
  #
  # <tt>laels</tt> :: 
  #       UserOption#label に登録された label の配列。長さ1..3。
  #       User#option にその値を持つuserOptionがあるとき、それぞれ@parmit、@editor、@configure の権限を与えられる。
  #       長さが3未満の時は、最後のlabelが使われる。
  def set_permit(labels)
    return unless current_user
    if @configure = current_user.option?( labels[2] ?  labels[2] : labels[-1])
      @editor = @permit = true
    elsif @editor = current_user.option?( labels[1] ?  labels[1] : labels[-1])
      @permit = true
    else
      @permit = current_user.option?( labels[0] )
    end
  end

  def permit(label=nil)
    @permit ||= current_user.option?(label)  if label
    @permit
  end
  def editor(label=nil)
    @editor ||= current_user.option?(label)  if label
    @editor
  end
  def configure(label=nil)
    @configure ||= current_user.option?(label)  if label
    @configure
  end
  def not_configure ; !configure ; end
  def not_editor ; !editor ;end
  def not_permit ; ! permit;end
  def require_permit_label(label,url="/404.html") 
    redirect_to url unless  permit(label)
    @permit
  end
  def require_permit(url="/404.html") 
    redirect_to url unless  @permit
    @permit
  end
  def require_editor(url="/404.html") 
    redirect_to url unless  @editor
    @editor
  end

  def require_configure(url="/404.html") 
    redirect_to url unless  @configure
  end
  ##########################
  def new
    @model = @Model.new(@New)
    if @edit_vertical
      render(  :file => 'application/new_vertical',:layout => 'application') unless @tmplate
    else
      render(  :file => 'application/new',:layout => 'application') unless @tmplate
    end
  end
  def create
    @model = @Model.new( permit_attr )#params[@Domain])
    if @Create 
      @Create.each{|k,v| @model[k] = v }
    end
    if @model.save
      page =  if @Pagenation
                (@Model.count(@FindOption||{}).to_f/@Pagenation).ceil
              end
      @models = @Pagenation ? pagenate(page) : find(page)
      redirect_to :action => "index" ,:page => page
      #render :action => :index
    else
      #@TYTLE = "複式簿記：振替伝票"
      logger.info("#{@Model.name} createエラー：#{@model.errors.full_messages.join(',  ')}")

      if @edit_vertical
        render(  :file => 'application/new_vertical',:layout => 'application') unless @tmplate
      else
        render(  :file => 'application/new',:layout => 'application') unless @tmplate
      end
    end
  end

  def find_and
    if @Pagenation && params[:parpage]
      @Pagenation = params[:parpage].to_i
    end
    @models=  @Pagenation ? pagenate(@page) : find(@page)
    @TYTLE_post = case @TYTLEpost
                  when Proc ; @TYTLEpost.call
                  when nil  ; ""
                  else      ; @TYTLEpost.to_s
                  end
    @models
  end

  def index
    @page = params[:page] || 1 
    find_and
    render  :file => 'application/index',:layout => 'application'
  end

  def edit
    @page = params[:page] || 1
    @back = params[:back]
    @back_params = params[:back_params]
    @model = @Model.find(params[:id])
    if @edit_vertical
      render(:file => 'application/edit_vertical',:layout => 'application') unless @tmplate
    else
      render(:file => 'application/edit',:layout => 'application') unless @tmplate
    end
  end


  def show
    @page = params.delete(:page)
    @model = @Model.find(params[:id])
    unless @tmplate
      if @show_vertical
        render  :file => 'application/show_vertical',:layout => 'application'
      else
        render  :file => 'application/show',:layout => 'application'
      end
    end
  end

  def update
    @page = params.delete(:page)
    @params = params
    @model = @Model.find(params[:id])

    if @model.update_attributes(params[@Domain]) 
      @Model.send(@Refresh,true) if @refresh #BookKamoku.kamokus true
      if params[:back]
        if params[:back_params]
          key,val = params[:back_params].split(",")
          redirect_to(:action =>  params[:back],key.to_sym => val)
        else
          redirect_to(:action =>  params[:back])
        end
      else
        redirect_to :action => "index" ,:page => @page
      end
    else
      if @edit_vertical
        render(:file => 'application/edit_vertical',:layout => 'application') unless @tmplate
      else
        render(:file => 'application/edit',:layout => 'application') unless @tmplate
      end
    end
    #end
  end

  def edit_on_table
    @models= find
    @page = params[:page] || 1 
    find_and
    render  :file => 'application/edit_on_table',:layout => 'application'
  end

  def add_on_table
    #@models= find #@Model.all(@conditions)
    @page = params[:page] || 1 
    @models= @PagenatTbl ? find_and : find #@Model.all(@conditions)#@PagenatTbl
    #find_and
    
    @add_no = params[@Domain][:add_no].to_i
    @maxid    = @models.size == 0 ? 1 : @Model.maximum(:id)+1
    @new_models = @add_no.times.map{model = @Model.new }
    @new_models.each_with_index{|model,id| model.id = id + @maxid}
    @models += @new_models
    render  :file => 'application/edit_on_table',:layout => 'application'
  end

  def cell_update
    @model = @Model.find(params[:id])
      logger.debug("#{@Domain}:cell_update #{@Domain},data #{params[@Domain]}")
    if @model.update_attributes(params[@Domain]) 
      render :text => "success"
    else
      logger.debug("#{@Domain}:cell_update faile #{@model.error}")
    end
  end

  def cell_edit
    @model =  @Model.find(params[:id])
    @html_cell = @labels[params[:column].to_i]
logger.debug("cell_edit:@html_cell=#{@html_cell.symbol} #{params[:row] }:#{params[:column]}")
    render  :file => 'application/cell_edit'
  end

  def update_on_table
    @page = params[:page] || 1 
    @models= @PagenatTbl ? find_and : find #@Model.all(@conditions)#@PagenatTbl
    @maxid    = @Model.count == 0 ? 0 : @Model.maximum(:id)
    @modelList = params[@Domain]
    @new_models = []
    @models = []
    @errors = []
    @result = true
    @modelList.each_pair{|i,model| id=i.to_i
      logger.debug("Update_on_table:#{i} #{id}#{@maxid} #{model}")
      if id >@maxid
        @model=@Model.new(model)
        @new_models << @model
        next if model.map{|k,v| v}.join == ""
        unless @model.save 
          @result = false 
          @errors <<  @model.errors if @model.errors.size>0
        end
      else
        #  unless UbeModel.new(model) == models[id]
        @mdl = @Model.find(id)
        @result &=  @mdl.update_attributes(model)
        @errors << @mdl.errors if @mdl.errors.size>0
        @models << @mdl
      end
    }
    if @result
      #UbeMeigara.meigaras true
      @Model.send(@Refresh,true) if @refresh #BookKamoku.kamokus true
      option = {:action =>  :index ,:page => @page}
      option.merge!(@option) if @option
      redirect_to option
    else
      @models.sort!{|a,b| a[@SortBy]<=>b[@SortBy]} if @SortBy
      @models += @new_models.sort{|a,b| a[:id]<=>b[:id]}
      render  :file => 'application/edit_on_table',:layout => 'application'
    end
  end
  def destroy
    @Model.find(params[:id]).destroy 
    @Model.send(@Refresh,true) if @refresh

    redirect_to :action => :index
  end


  def change_per_page
    if params[:line_per_page] && params[:line_per_page].to_i > 0
      @page = (((params[:page].to_i-1) * @Pagenation) / params[:line_per_page].to_i).to_i+1
      @Pagenation =  session[self.class.name + "_per_page"] = params[:line_per_page].to_i
    else 
      @page = params[:page]
    end
    find_and
    render  :file => 'application/index',:layout => 'application'
  end

  def csv_out(filename=nil)
    models = find
    csv_out_comm(models,filename)
  end

  def csv_out_comm(models,filename)    
    filename ||= @CSVfile || (current_user.username+@Model.name.underscore+".csv")
    tmpfile = @Model.csv_out(models,:columns => @CSVatrs,:labels => @CSVlabels)
    send_file(tmpfile,:filename =>  filename)
  end
  def csv_upload
    errors= @Model.csv_upload(params[:csvfile], @CSVlabels,@CSVatrs)
    unless errors[0]
      flash[:message] = errors[1]
      redirect_to :action => :index
    else
      @Model.send(@Refresh,true) if @Refresh
      flash[:message] = errors[1] if  errors[1]>""
      redirect_to :action => :index
    end
  end

  def lastpage
    page = (@Model.count(@FindOption||{}).to_f/@Pagenation).ceil 
    page > 0 ? page : nil
  end

  def find(page=1); @Model.all(@FindOption||{});end

  def pagenate(page=1)
    page=1 unless page.to_i >0
    @Model.paginate((@FindOption||{}).merge({ :page => page,:per_page => @Pagenation}))
  end
  def attr_list
    @labels.map{|html_cell| html_cell.symbol}
  end

  def permit_attr
    params.require(@Domain).permit(attr_list)
  end
end

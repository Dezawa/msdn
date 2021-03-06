# -*- coding: utf-8 -*-
# --
#  Filters added to this controller apply to all controllers in the application.
#  Likewise, all the methods added will be available for all controllers.
# ++
require 'html_cell'

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

  def model(the_model)
    @Model = the_model
    @Domain= @Model.name.underscore
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
                (@Model.where(@FindWhere).count.to_f/@Pagenation).ceil
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
    @TYTLE_post = case @TYTLE_post
                  when Proc ; @TYTLE_post.call
                  when nil  ; ""
                  else      ; @TYTLE_post.to_s
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

    if @model.update_attributes(permit_attr)#params[@Domain]) 
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
    @new_models = new_models
    @models += @new_models
    render  :file => 'application/edit_on_table',:layout => 'application'
  end

  def new_models
    @maxid    = @models.size == 0 ? 1 : @Model.maximum(:id)+1
    models = @add_no.times.map{model = @Model.new }
    models.each_with_index{|model,id| model.id = id + @maxid}
    models
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
logger.debug("cell_edit:@html_cell=#{@html_cell.symbol} #{params[:row]}:#{params[:column]}")
    render  :file => 'application/cell_edit'
  end

  def update_on
    @new_models = []
    @errors = []
    @result = true
    @modelList.each_pair{|i,model| id=i.to_i
      logger.debug("Update_on_table:#{i} id=#{id} maxid=#{@maxid} #{model}")
      case model
      when ActionController::Parameters
        model = model.permit( attr_list )
      when ActiveSupport::HashWithIndifferentAccess,Hash
      end

      if id >@maxid
        next if model.map{|k,v| v}.join == ""
        @model=@Model.new(model)
        if @model.save 
          @new_models << @model
        else
          @result = false 
          @errors <<  @model.errors if @model.errors.size>0
        end
      else
        #  unless UbeModel.new(model) == models[id]
        @mdl = @Model.find(id)
        @result &=  @mdl.update_attributes(model) # @model.update_attributes(permit_attr)
        @errors << @mdl.errors if @mdl.errors.size>0
        @models << @mdl
      end
    }
  end
  def update_on_table
    @page = params[:page] || 1
    @models = [] 
    @models= @PagenatTbl ? find_and : find #@Model.all(@conditions)#@PagenatTbl
    @maxid    = @Model.count == 0 ? 0 : @Model.maximum(:id)
    @modelList = params[@Domain] || { }
    update_on
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

  # have_many :through に於いて、関連だけ削除する。
  # applycation_helper# delete_connection_if_accepted(obj) と連動
  #  throughに使うテーブルのModelを@AssociationTableに定義する
  def delete_bind
    if @ThroughTable
      @ThroughTable.delete(params[:bind_id])
    else
      @Model.find(params[:id]).send(@assosiation).delete(@AssociationTable.find(params[:bind_id]))
    end
    redirect_to :action => :show,:id => params[:id]
  end

  def edit_assosiation
    @model = @Model.find(params[:id])
    @assosiations = @model.send(@assosiation)
    render  :file => 'application/edit_association',:layout => 'application'
  end

  def image(graph_file)
    "image/#{File.extname(graph_file)}"
  end

  def show_img
    graph_file = (params[:graph_file].blank? ? "image.jpeg" : params[:graph_file])
    send_file( Rails.root+"tmp/img/#{graph_file}",
               :type => image(graph_file), :disposition => 'inline' )
  end
  def graph
logger.debug("APPLICATION#GRAPH: params=#{params.to_a.flatten.join(',')}")
  end


  def update_assosiation
    model  = @Model.find(params[:id])
    @models= model.send( @assosiation)
    @Model  = @ThroughTable || @AssociationTable
    @maxid = @Model.count == 0 ? 0 : @Model.maximum(:id)
    @modelList = params[:assosiation]
    update_on
    model.send( @assosiation) << @new_models
    redirect_to :action => :show,:id => params[:id]
  end

  def add_assosiation
    @model = @Model.find(params[:id])
    assoc_table = @ThroughTable || @AssociationTable
    @assosiations= @model.send(@assosiation)
    #find_and
    
    @add_no = params[:assosiation][:add_no].to_i
    @maxid    = @assosiations.size == 0 ? 1 : assoc_table.maximum(:id)+1
    @new_models = @add_no.times.map{model = assoc_table.new }
    @new_models.each_with_index{|model,id| model.id = id + @maxid}
    @assosiations += @new_models
    render  :file => 'application/edit_association',:layout => 'application'

  end

  def change_per_page
    if params[:line_per_page] && params[:line_per_page].to_i > 0
      @page = (((params[:page].to_i-1) * @Pagenation) / params[:line_per_page].to_i).to_i+1
      @Pagenation =  session[@PageSession] = params[:line_per_page].to_i
    else 
      @page = params[:page]
    end
    redirect_to :action => :index,:page => @page
  end

  def csv_out(filename=nil)
    models = find
    csv_out_comm(models,filename)
  end

  def csv_out_comm(models,filename)
    @CSVatrs  = @CSVlabels = @Model.column_names unless @CSVatrs && @CSVlabels
    filename ||= @CSVfile || (current_user.username+@Model.name.underscore+".csv")
    tmpfile = @Model.csv_out(models,:columns => @CSVatrs,:labels => @CSVlabels)
    send_file(tmpfile,:filename =>  filename)
  end

  def csv_upload
    @CSVatrs  = @CSVlabels = @Model.column_names unless @CSVatrs && @CSVlabels
    errors= @Model.csv_upload(params[:csvfile]||params[@Domain][:csvfile], @CSVlabels,@CSVatrs)
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
    page = (@Model.where(@FindWhere).count.to_f/@Pagenation).ceil 
    page > 0 ? page : nil
  end

  def find(page=1); @Model.where(@FindWhere).order(@FindOrder);end

  def pagenate(page=1)
    page=1 unless page.to_i >0
    @Model.where(@FindWhere).order(@FindOrder).
      paginate( :page => page,:per_page => @Pagenation)
  end
  def attr_list(labels = nil)
    labels ||= @labels
    labels.select{ |lbl| !lbl.ro}.map{|html_cell| html_cell.symbol}
  end

  def permit_attr
    params.require(@Domain).permit(attr_list)
  end

end

# -*- coding: utf-8 -*-
class Book::MainController < Book::Controller
  #include BookPermit
  #before_filter :authenticate_user! 
  before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  #before_filter {|ctrl| ctrl.require_permit "/msg_book_permit.html"}
  before_filter(:only => :csv_upload){|ctrl| ctrl.require_book_editor( "/msg_book_permit.html");false}
  before_filter :set_instanse_variable
  before_filter :set_const
  before_filter(:except => :error     ) {|ctrl|  ctrl.require_allowed "/book_keeping/error" }

  # 試用ユーザが持てる最大のデータ数（年度毎）
  # これを越えると越えた分古いレコードから削除される
  TrialLimit = 100

  # index,new,edit,で用いる。インスタンス表示の項目一覧
  #           項目のsymbol、項目名、不使用、項目のtype、input_fieldでの幅
  #　　　　　　第４要素は、typeが :select であったときはchoiceを記述する。
  # なお、この各要素は変数であっても初期化時の値となりダイナミックに
  # 変わらない。第４要素に関しては、ここが　Proc classであったときは、
  # 実行時に評価され直される
  Labels = 
    [ HtmlText.new(:id,"ID",:align =>:right,:ro=>true,:size =>7),
      HtmlText.new(:no,"通し番号",:align =>:right,:size =>3),
      HtmlDate.new(:date,"日付",:tform=>"%Y-%m-%d",:size =>8),
      HtmlText.new(:amount,"金額",:align =>:right,:size =>7),
      HtmlSelect.new(:karikata,"借方勘定",:display=>:kari_kamoku_name,:help => "Book#kamoku",:include_blank => true),
      HtmlSelect.new(:kasikata,"貸方勘定",:display=>:kasi_kamoku_name,:help => "Book#kamoku",:include_blank => true),
      HtmlText.new(:tytle,"摘要",:size =>30),
      HtmlText.new(:memo,"メモ",:size =>30)
    ]
  CSVatrs = Labels.map{|lbl| lbl.symbol}
  CSVlabels= Labels.map{|lbl| lbl.label}
 # 勘定元帳を表示する
  LabelsBookMake=[
                  HtmlDate.new(:date    ,"日付"   ,:tform=>"%Y-%m-%d"  ),
                  HtmlText.new(:tytle   ,"摘要"   ,:link => "sort_by_tytle"  ),
                  HtmlText.new(:memo    ,"メモ"     ),
                  HtmlText.new(:aite    ,"相手課目"  ),
                  HtmlText.new(:kasi    ,"借方"    ,:align => :right),
                  HtmlText.new(:kari    ,"貸方"    ,:align => :right),
                  HtmlText.new(:kasikari,""        ),
                  HtmlText.new(:sum     ,"差引残高",:align => :right)
                 ]

  # 勘定元帳の表示項目
  Motocho = [
             HtmlDate.new(:date,"日付",:size=>7),
             HtmlText.new(:tytle,"摘要",:size=>10),
             HtmlText.new(:memo,"メモ",:size=>10),
             HtmlText.new(:amount,"金額",:align=>:right,:size=>7)
            ]

  Comment = "日付、金額、貸方・借方勘定、摘要は必須です<br><hr>\n" +
    "勘定課目のどちらが借方貸方か分からなくなったとき"+
    "「現金」を介在させて考えると間違えにくいです。<br>\n"+
    "例えば<br>"+
    "クレジットカードで払った通信費3000円が引き落とされたとき<br>\n"+
    "「クレジット会社に現金で支払い、預金から現金3000円財布に入れた」<br>\n"+
    "と考えると、クレジット会社に支払うと現金が減るから貸方<br>\n"+
    "すなわち<br>\n"+
    "　　　借方　　 金額　 貸方<br>\n"+
    "　　　未払金　3000　現金　クレジット会社に現金で支払い<br>\n"+
    "　　　現金　　3000　預金　預金から引き落とし<br>\n"+
    "で相殺して<br>"+
    "　　　未払金　3000　預金"
  def set_const
    @Model= Book::Main

    # year= @year_beginning =  @year.beginning_of_year
    # @year_end       =  @year.end_of_year
    # @year_full = year
    @TYTLE = "#{@owner.owner}の 複式簿記：振替伝票"
    @TYTLEpost = "#{@year}年度"
    #@Links=BookKeepingController::Labels
    @FindOption = ["owner = ? and date >= ? and date <= ?",
                     @owner.owner, @year_beginning,@year_end]
    @FindWhere = ["owner = ? and date >= ? and date <= ?",
                     @owner.owner, @year_beginning,@year_end]
    @FindOrder  =   "no"
    
    @TableEdit = 
      unless editable ; false
      else
        base = [[:form,:new,"新伝票",method: :get],[:form,:renumber,"整列"],[:form,:edit_on_table,"編集"]]
        base.push([:form,:make_new_year,"新年度初期化"]) if kaisizandaka_count == 0
        base
      end
    @edit_vertical = true
    @Edit = editable
    @Delete=editable
    #@conditions = { :order => "bunrui,kamoku" }

    @Domain=  @Model.name.underscore
    choice = Book::Kamoku.kamokus(@owner.owner)
    @labels=Labels
    [4,5].each{|idx| @labels[idx].correction = choice}
    #@SortBy   = :bunrui
    @CSVatrs = CSVatrs; @CSVlabels = CSVlabels
    @CSVfile = @owner.owner+"_#{@Domain}.csv"
    @PageSession="BKMain_per_page"
    @Pagenation = session[@PageSession] || (session[@PageSession] = 10)
    #@page = params[:page] || :lastpage
    @PagenatTbl = true
    maxNo = Book::Main.this_year( @owner.owner,@year_beginning,@year_end).maximum(:no)
    #maxNo  = Book::Main.this_year(@owner.owner,@year_beginning,@year_end).maximun(:no)
    no = (maxNo ? maxNo : 0) + 1
    @New = {:no => no, :date => Time.now,:amount => ""}
    @Create = {:owner => @owner.owner } #current_user.login }
    @PostMessage = Book::MainController::Comment
  end

  def count
    Book::Main.where( ["owner = ? and date >= ? and date <= ?",
                          @owner.owner,@year_beginning,@year_end]).count
  end

  def kaisizandaka_count
    Book::Main.where(["owner = ? and date >= ? and date <= ? and (karikata = ? or kasikata = ?)",
                      @owner.owner,@year_beginning,@year_end,
                      Book::Kamoku.kaisizandaka,Book::Kamoku.kaisizandaka
                     ]).count
  end

  def index
    @page = params[:page] || lastpage
    if !@arrowed && (over = count - TrialLimit)>0
      (1..over).each{
        model = @Model.first(@FindOption).destroy
      }
      flash[:message] = "試用ユーザの最大データ数#{TrialLimit}を越えたので、古いものを削除しました。"
    end
    find_and
    render  :file => 'application/index',:layout => 'application'
  end

  def destroy
    unless @Model.find(params[:id]).editable?(current_user.username)
      redirect_to "/msg_book_permit.html"
    else
      super
    end
  end

  # 一覧からの「整列」のアクション。日付順に並べ替える
  def renumber
    Book::Main.renumber(current_user.username,@year)
    redirect_to :action => :index ,:page => @page
  end

  # 勘定元帳を表示する
  def book_make
    @kamoku_id = session[:BK_kamoku_id] = params[:kamoku_id]
    #kamoku    = params[:kamoku]
    @TYTLE = Book::Kamoku.find(@kamoku_id).kamoku
    @labels= LabelsBookMake
    @models = Book::Main.book_make(@kamoku_id,current_user.username,@year)
  end

  def sort_by_tytle
    @kamoku_id = session[:BK_kamoku_id]
    @TYTLE = Book::Kamoku.find(@kamoku_id).kamoku
    @labels= LabelsBookMake
    @models = Book::Main.book_make(@kamoku_id,current_user.username,@year).
      sort{ |booka,bookb| ((booka.tytle<=>bookb.tytle) << 2) + ((booka.date <=> bookb.date) << 1) + (booka.no <=> bookb.no)}
    render :action => :book_make
  end

  def make_new_year
     Book::Main.make_new_year(@owner.owner,@year)
    find_and
    set_const
    render  :file => 'application/index',:layout => 'application'
  end

  def csv_out_print
    tmpfile = Book::Main.csv_out_print(current_user.username,@year)
    send_file(tmpfile,:filename => (@owner.owner + "_book.csv"))
  end

  def csv_upload
    unless book_editor?
      redirect_to "/msg_book_permit.html"
    else
      error = Book::Main.update_by_csv(params[:csvfile], @owner.owner,CSVlabels,CSVatrs)
      
      if !@editor && (over = count - TrialLimit)>0
        (1..over).each{
          model = @Model.first(@FindOption).destroy
        }
        error.unshift "試用ユーザの最大データ数#{TrialLimit}を越えたので、古いものを削除しました。"
      end
      flash[:message] = 
        if (msg =error.uniq.join("<br>\n")).size < 2800
          msg
        else
          msg[0..2700]
        end
      redirect_to :action => :index
    end
  end
end

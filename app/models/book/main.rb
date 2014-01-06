# -*- coding: utf-8 -*-
# 複式簿記のアプリ BookKeeping 
# BookKeepingはModelはなく、CVのみ。
# このBookMAinが主なModel
# オカレンスは振替伝票
# column owner とloginが一致しないと読まれない。
# 勘定元帳、貸借対照表(と損益計算書)総勘定元帳を作る classメソッドがある
# また、それらを印刷用CSVに書き出すclassメソッドがある。
class Book::Main < ActiveRecord::Base
  extend CsvIo
  self.table_name = 'book_mains'
  before_validation      :no_check
   validates_presence_of :no,:date ,:message=> "は必須項目です"
   validates_presence_of :karikata ,:message=> "借方勘定科目は必須項目です"
   validates_presence_of :kasikata ,:message=> "貸方勘定科目は必須項目です"
   validates_presence_of :amount   ,:message => "金額は必須項目です"
   validates_presence_of :tytle,:message => "摘要は必須項目です"

  attr_accessor :kasi, :kari, :aite, :kasikari, :sum
  #validates :tytle   ,:presence => true,:message => "摘要は必須項目です"
  belongs_to :kari_kamoku,:class_name => "Book::Kamoku",:foreign_key => :karikata
  belongs_to :kasi_kamoku,:class_name => "Book::Kamoku",:foreign_key => :kasikata

  # 所有者、日付を指定して伝票を読む
  def self.this_year_of_owner(owner_name,date)
    self.this_year(owner_name,date.beginning_of_year)
  end
  def self.this_year_of_owner_sort_by_date(owner_name,year)
    from = year.beginning_of_year
    to = year.end_of_year
    where(["owner = ? and date >= ? and date <= ?", owner_name,from,to]).
      order(["date","no"])
  end

  scope :this_year, ->(owner_name,from,to=nil) { 
    to ||= from.end_of_year
    where(["owner = ? and date >= ? and date <= ?", owner_name,from,to]).
    order(:no)
  }

  def no_check
    no || self[:no] = Book::Main.maximum(:no) + 1
  end
  
  def self.new(*args)
    arg = args.first || {}
    arg[:amount] ||= ""
    arg[:amount].gsub!(/,/,"") if arg[:amount].class == String
    super
  end

  
  # 日付が前後したときに日付順に並べ直す
  def self.renumber(login,year)
   models= self.this_year_of_owner_sort_by_date(login,year)
    numbers = models.map(&:no).sort
    ids     = models.map(&:id).sort
    models.each_with_index{|model,idx|
      next if model.no == idx+1 #numbers[idx]
      model.update_attributes(:no => idx+1 )#numbers[idx])
    } 
  end

  # csvからデータを入れ直す。
  # IDが一致する場合はupdate、一致するものが無い場合はcreateする。
  # ownerが異なる場合は :editable が false し、updateしない
  def self.update_by_csv(csvfile,user,labels,columns)
    @@user = user
    #labels = columns = %w(id no date karikata kasikata tytle memo amount owner)
    csv_update(csvfile,labels,columns,{:condition => :editable_by_user?,:owner => user})
  end

  # 振替伝票の一覧を印刷用のCSVにする。
  # csv_outと異なるのは、貸方、借方が BookKamoku#id ではなく、名称になる。
  # なお、csv_out はモジュール CsvIo で記述
  def self.set_to_array_for_print(login,year)
    models= self.this_year_of_owner( login,year)
    columns = %w(no date karikata kasikata tytle memo amount)
    ary = [ %w(番号 日付 貸方 借方 備考 メモ 金額)]
    models.each{|model|  ary << columns.map{|clm|
        %w(karikata kasikata).include?(clm) ?  Book::Kamoku.kamokus.rassoc(model[clm])[0] : model[clm]
      }
    }
    ary
  end

  def self.csv_out_print(login,year)
    csv_out(set_to_array_for_print(login,year))    
  end

  # 元帳データを作る。
  BookMakeSql = "owner = ? and ( karikata = ? or kasikata = ? ) and date >= ? and date <= ?"
  def self.book_make(kamoku_id,login,year)
    
    books = 
      Book::Main.where( [BookMakeSql,
                         login,kamoku_id,kamoku_id,
                         year.beginning_of_year,year.end_of_year
                        ]).
      order("no")
    sum = 0
    books.each{|book| 
      next unless book.amount
      aite =  book.karikata
      book.kari=book.kasi = nil
      if kamoku_id.to_i == book.karikata
        aite = book.kasikata
        book.kasi = book.amount
        sum -= book.amount
      else
        book.kari = book.amount
        sum += book.amount
      end
      aite = Book::Kamoku.kamokus.rassoc(aite)[0]
      book.aite     =aite
      book.kasikari = sum >0 ? "貸" : "借"
      book.sum      = sum.abs
    }
  end

  def self.recalc_motoirekin(table)
    bunrui_motoire,bunrui_kari,bunrui_kasi = %w(元入金 事業主借 事業主貸).
      map{|kamoku| Book::Kamoku.find_by(kamoku: kamoku).bunrui}
    table[bunrui_motoire] = 0 #+= table[bunrui_kari] - table[bunrui_kasi]
    table[bunrui_kari] = table[bunrui_kasi] = 0
    table
  end

  def self.make_new_year(login,year)
      sisan = sihon = 0
    kamokus = Book::Kamoku.all(:conditions => ["code < ?",4]) #資産 負債 資本
    table = recalc_motoirekin(sum(login,year-1.year)).
      to_a.sort.each{|bunrui,mount|
      next if bunrui > 399 || bunrui < 1 || mount == 0
      #pp [bunrui,mount,Book::Kamoku.find_by_bunrui(bunrui)]
      if bunrui < 199  # 資産
        create!( :karikata => Book::Kamoku.findA_by(bunrui: bunrui).id,
                 :kasikata => Book::Kamoku.kaisizandaka,
                 :owner => login,
                 :amount   => mount,
                 :date     => year.beginning_of_year,
                 :no       => 1,
                 :tytle    => "開始残高")
        sisan += mount
      else #負債 資本
        create!( :karikata => Book::Kamoku.kaisizandaka,
                 :kasikata => Book::Kamoku.find_by(bunrui: bunrui).id,
                 :owner => login,
                 :amount   => mount,
                 :date     => year.beginning_of_year,
                 :no       => 1,
                 :tytle    => "開始残高")
        sihon += mount
      end
    }
    create!( :karikata => Book::Kamoku.kaisizandaka,
                 :kasikata => Book::Kamoku.find_by(kamoku: "元入金").id,
                 :owner => login,
                 :amount   => sisan-sihon,
                 :date     => year.beginning_of_year,
                 :no       => 1,
                 :tytle    => "開始残高")
  end

  # 総勘定元帳のデータをArryのArrayで作る
  # 印刷用CSV出力のデータ
    def self.motocho(login,year)
    table = [[nil,"総勘定元帳",nil,year.year,"年度"]]
    table << [nil]
    Book::Kamoku.order("bunrui").each{|kamoku|
      books=book_make(kamoku.id,login,year)
      if books.size>0
        table << [nil,kamoku.kamoku,nil,year.year,"年度"]
        table << ["年月日","摘要","メモ","相手科目","貸方","借方","","差引残高"]
        books.each{|book|
          table << [book.date,book.tytle,book.memo,book.aite,
                  book.kasi,book.kari,book.kasikari,book.sum]
        }
        table << [nil]<< [nil]
      end
    }
    table
  end

  # 各課目の合計を求める
  #　借方の課目が借方にあれば 負
  #　　　　　　　貸方にあれば 正
  #　貸方の課目が借方にあれば 負
  #　　　　　　　貸方にあれば 正
  #  で良いのかなぁ、、、　　　　　　　　現金 預金 手形 交通 売上 未払
  #  現金  売上      現金 正  売上 負　　　１                -1
  #  預金　現金      預金 正  現金 負    　 0   1　　　　　　-1
  #  手形  売上      手形 正  売上 負           1    1       -2
  #  預金  手形      預金 正  手形 負           2    0       -2
  #  交通  未払      交通 正  未払 負           2        1   -2    -1
  #  未払  預金      未払 正  預金 負           1        1   -2     0
  #  預金  交通      預金 正  交通 負           1        0   -2     0
  def self.sum(login,year,condition="")
    period ||= [year.beginning_of_year,year.end_of_year]
    @@sum = Hash.new{|h,k| h[k]=0}
    books = Book::Main.where( ["owner = ? and date >= ? and date <= ? "+condition,
                                          login,period[0],period[1] ])
    books.each{|book|
      @@sum[book.kariKata.bunrui] += book.amount* book.kariKata.taishaku
      @@sum[book.kasiKata.bunrui] -= book.amount* book.kasiKata.taishaku
    }
    @@sum
  end

  # 貸借対照表のデータをArrayのArrayで作る
  # このデータで印刷用CSV出力、Viewの出力に用いる
  def self.taishaku(login,year)
    taishaku_end = self.sum(login,year)
    taishaku_begin = self.sum(login,year,
                              "and (karikata = #{Book::Kamoku.kaisizandaka} or kasikata = #{Book::Kamoku.kaisizandaka})")
    # Hashから貸借対照表的な配列を作る。
    # 科目を 貸借と損益、借方貸方に分ける
    #        貸借借方貸方 => 0 損益借方貸方=> 1
    bookKamoku_all = Book::Kamoku.order( "bunrui")
    kamoku  = [[bookKamoku_all.select{|k| k.code == 1},  # 資産 貸借貸方
                bookKamoku_all.select{|k| k.code == 2 || k.code == 3}], #負債,資本 貸借借方
               [bookKamoku_all.select{|k| k.code == 5},  # 経費 損益貸方
                bookKamoku_all.select{|k| k.code == 4}]  # 収入 貸借借方
              ]
    size = kamoku.map{|klist| 
      klist[0].size > klist[1].size ? klist[0].size : klist[1].size
    }
    # 結果配列
    table = []
    # ヘッダー部
    table << [nil,nil,"貸借対照表"]
    table << [nil]*4 +[year.year,"年度"]
    table << ["資産の部",nil,nil,"負債・資本の部"]
    table << ["科目",year.beginning_of_year.strftime("%m月%d日"),
              year.end_of_year.strftime("%m月%d日")]*2
    # 利益の計算の箱
    profit = [0,0]  
    # ,合計計算の箱   貸方 借方 の 期首期末
    total  = [[0,0],[0,0]]
    
    # 
    [0,1].each{|i| # まず 貸借 そして 損益
      (0..size[i]-1).each{|j|  # 科目を順に
        table << (0..1).map{|l|  m = (l==0 ? 1 : -1)*(i==0 ? 1 : -1)      # 貸方 借方
          if (k = kamoku[i][l][j])
            profit[i] += taishaku_end[k.bunrui] * m
            total[l][0] += taishaku_begin[k.bunrui] 
            total[l][1] += taishaku_end[k.bunrui] 
            [k.kamoku,taishaku_begin[k.bunrui],taishaku_end[k.bunrui]]
          else
            [nil,nil,nil]
          end
        }.flatten
      }
      table << [nil,nil,nil,"利益",nil,profit[i]]
    }
    table[-1] = table.last[3,3]+[nil,nil,nil] 
    table << [nil]+total[0].flatten+[nil]+total[1].flatten

    #keys=(taishaku_end.keys + taishaku_begin.keys).uniq.sort
    #[taishaku_begin,taishaku_end,keys,table]
    table
  end

  # 対照年度を西暦で持つ。
  # 設定時に期首、期末の日付も設定する。
  def self.dddddyear(y=nil)
    if y || $year.nil?
      $year = Time.now.beginning_of_year unless y
      $year = Time.gm(y).beginning_of_year if y
      $year_end = $year.end_of_year
    end
    $year.year
  end

  # 期首の年月日を返す
  def self.dddddyear_end 
    self.year unless $year_end
    $year_end
  end
  
  # 期末の年月日を返す
  def self.dddddyear_begin 
    self.year unless $year
    $year
  end
  
  ##################################################################################
  def deletable?(login)
    owner == login
  end
  def before_save
    #if (s= BookMain.sum.inject(0){|s,v| s += v[1]}) != 0
    #  errors.add_to_base("貸借が一致しません 不一致額 #{s}")
    #end
    true
  end

  def varidate   
    #if (s= BookMain.sum.inject(0){|s,v| s += v[1]}) != 0
    #  errors.add_to_base("貸借が一致しません 不一致額 #{s}")
    #  false
    #else
    #  true
    #end
true
  end

  # 貸方の科目を返す
  def kariKata
    @kari ||= Book::Kamoku.find(karikata)
  end

  def kari_kamoku_name ; kari_kamoku ? kari_kamoku.kamoku : nil ;end

  # 借方の科目を返す
  def kasiKata
    @kasi ||= Book::Kamoku.find(kasikata)
  end
  def kasi_kamoku_name ; kasi_kamoku ? kasi_kamoku.kamoku : nil ;end

  # 持ち主かどうか
  def editable_by_user?
    logger.debug("### editable #{owner} #{@@user} ##")
    editable?(@@user)
  end

  def editable?(login)
    login == owner || owner == "guest" ||
      (bp = Book::Permission.find_by(login: login,owner: owner)) &&
      bp.permission == Book::Permission::EDIT
  end

  def readable?(login)
    login == owner ||
      (bp = Book::Permission.find_by(login: login,owner: owner)) &&
      bp.permission > Book::Permission::NON
  end
end

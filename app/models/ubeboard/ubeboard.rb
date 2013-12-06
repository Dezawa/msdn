# -*- coding: utf-8 -*-
#===ウベボード生産計画立案
#このModelはウベボード生産計画立案サポートシステムのドキュメント用のModelファイルです
#* UbeboardControllerなどはありますが、それとの関連はないです。名前の再利用
#==生産計画
#* 工程の概要 operation
#* 品種・製品・銘柄 production
#* 保守 maintain
#* 切り替え時間 change_time
#
#===制約条件 reguration
# 工程間待ち時間上限、移動時間、切り替え時間、製造数、定期的保守などの制約が有る。
#
#===アルゴリズム argorism
# いくつかの方法を検討したが、現在は7改を採用している。UbeSkd#make_plan7
# この肝は Function::UbeOptimize#optimize での次の割付ラウンド決定
# 
# その後の再検討

"
手作業で立てた月度計画6月の各日の分が休日までに収まらない。
そのとき乾燥機待ちで大きく穴があく

1.養生前後の時間が開きすぎるとき、抄造も遅らせる必要が有るときには、そのロットはパス
　　　　パスするのは、assign_temp_and_real の結果を見て
　これは優先順でなければうまくいかない
　優先順でも、おなじラインの組み合わせが続くとずっとパスされてしまう
2.最適化を入れる
　　　ラウンドのトップがOKならラウンドを採用
　　　　　乾燥待ちのロットが出た時点で残りはパス
　　　優先順の高いラウンドのトップが乾燥待ちになるようなら、そのラウンドは待ち。
　　　　　別の乾燥ラインのラウンドの優先順の高い方を選ぶ。
さらに
1. ラウンドの途中で休日になってしまったとき、そのラウンドはそこで終了
2. ラウンド最後のロットは、残り時間でできる数量に減らす。

　　休日を挟んだかどうかの判断はpre_conditionの終了時間と仮割付の開始時間の差が、休出の
    ときの16時間+始業+終業(16+2+0~5=18〜23)以上のとき  
      短すぎるかなぁ、、、、
    beyond_holyday で定義する。16はclass定数 BeyondHolydayで定義する。
    
    判断は、
        Function::UbeSkdFreelist#biyond_holyday?(real_ope,start)
    判断を行うのは、temp_assign_all_plan を呼んだ直後
        trueであったら残り時間で可能な数量に減らして再割付する。
              極少ない(MassLimit未満)場合はこのラウンド終了
        ただし
        優先順モードのときとラウンド最初のロットの場合は休日明けでよいので、この判断自体を行わない
               

   残り時間で作れる量をどう求めるか。すなわち残り時間をどう求めるか
      pre_conditionの終了時間をパラメータにして、残り時間を返すmethodを用意する
        Function::UbeSkdFreelist#rest_time(real_ope,start) => [start,end]

   更なる検討
      休日前に時間を余してラウンドが,終わると次のラウンドの最初のロットが前置き超過してパスされる
      事が起きる。これが起きるとその後ずっとそうなってしまう。
          前のラウンドの数量が少ないときも有るし、乾燥が一杯になって打ちきられることもある。
      これを防ぐには。。。。。
        ラウンドの最初のロットが 「前置き超過で抄造開始を遅らせる」のはよしとする。


   立案を左右する定数は、定数用のDBを設けて、そこで管理してもらうのがよいのか？
       製造数量が半端になったとき、最低製造数量
       休日前に製造する最後のロットでは最低何枚
       抄造工程終業作業時間
       抄造工程始業作業時間
"

#===実装
#すべてのアルゴリズムは次の手順となっている 
#1. 新規、仕掛かり、完了で処理内容、処理順が異なるので、まずそれを分ける。 UbeSkd#sorted_plan
#*  UbeSkd#sorted_plan はsize 3 の配列を返す[完了,仕掛かり,新規]
#2. 立案期間の稼働時間、休日、休転情報から、空き時間リストを初期化する
#3. 実績を元に
#     既に使われた時間を空き時間から削除する
#     工程の状態を得る（最終ロットの品種、終了日時、稼働累積）
#4. 仕掛かりを仕上げる Function::UbeSkdHelp#procceed_stock
#5. 新規の中からアルゴリズムで選ばれたラウンドを割り付ける F
#    Function::UbeOptimize#optimize でラウンド選定
#    UbeSkd#assign_plans で割付
#      養生庫を割り当てる。 Function::UbeSkdHelp#get_yojoko
#      割り付ける    UbeSkd#assign_temp_and_real
#         仮押さえ  Function::UbeSkdHelp#temp_assign_all_plan
#           乾燥まで仮押さえし、前置き、後置きの時間超過を調整する
#         押さえた時間で割付 Function::UbeSkdHelp#assign_maint_plan_by_temp
#
#6. 新規が無くなるか、工程に空きが無くなるまで繰り返す。
#7. 稼働累積を計算し、警告・エラー通知とともに保存する。
#    
#==変更への対応
#===工程・ラインの増減
#一番ありそうなのが養生庫。これは UbeYojo::Yojoko を修正する
#===品種・製品・銘柄の増減
#1. 品種の増減
#*   UbeOperation, UbeChangeTime への登録
#2. 製品の増減
#*   UbeProduct への登録。
#3. 銘柄の増減
#*   UbeMeigara への登録
#===記名切替の増減
#* UbeSkd.ChangeTimeLimit より時間が長いこと、が満たされれば
#* UbeNamedChange と UbeProduct に登録すればよい
#* UbeSkd::ChangeTimeLimit より時間が長いが記名不要の場合は、 UbeNamedChange に載せない。
#===保守の増減
#UbeProduct に名称とA??を登録する。
#Function::UbeSkdHelp#maintain を修正する
#
#==以下未整理
#pre_conditionを初期化する。 　これは、実績時間の割付のときに行う    
#    
#養生庫を初期化する　　　　　  これは、実績時間の割付のときに行う  
#    
#実績時間を割り付ける（空き時間から削除する）→ assign_if_resulted    
#   実績時間を空き時間から削除する。
#   開始のみで終了がない場合は所要時間を求めて割り付ける
#   pre_conditionの設定、養生庫のassidnを行う
#     この二つは最初のアクセスのときに、初期化される
#    
#仕掛品を完了まで割り付ける    
#   工程が先まで進んでいるものから順に片付ける 
#    
#===仕掛品など、前処理
#
#
#
#
#====養生の場合
#無条件で 保守・切り替え時間 なし、指定された開始時間から割付 で確保する。
#
#理由
# - 養生には定期保守はないので、3.保守に要する時間 は無い
# - 抄造を割り付けるに当たって、養生庫は指定されている。
#   指定に当たって養生庫を決めるには、抄造終了時に利用開始可能でその後40時間空いているもの
#   を選びこの時移動時間も考慮している。ので、改めて調べる必要が無い。
#
#== Model
# 　マスター系
# 　　
# 
# 各製品、各工程のunit time,ロットサイズ、工程切り替え時間の管理
#     ３つのModel UbeProduct,UbeOperation,UbeChangeTime で管理する。
# 
#UbeProduct
#     製品名、ロットサイズ、抄造機、乾燥機 の他に、工程条件の名前を、抄造、乾燥、加工分もつ
# 
#UbeOperation
#     工程、工程条件 毎に unit time を持つ
# 
#UbeChangeTime
#     工程、前製品の工程条件、次製品の工程条件 の組み合わせ毎に、切り替え時間を持つ
#     
#   これらのModelの 工程条件名には 東西原新 のsufix がつく。つけば　抄造または乾燥。
# 
#   
# 　unit time を得るには  
#     unit time は、UbeOperation から、抄造 type、乾燥type、加工typeをKeyに得る。
#     これは SQLで一度に取っておく
#     
#   切り替え時間を得るには1
#     各工程の割付状況はlistでもっておく。
#     これを元に、前回の製品名を得、工程typeを得て、UbeChangeTimeから 前後工程typeをkeyに得る。
# 
#     これは、model UbeSkd にて、memoしておく。
#     def change_time(前製品 工程type,後製品 工程type)
#        @change_time ||= Hash.new
#        unless @change_time( [前製品 工程type,後製品 工程type] )
#          @change_time( [前製品 工程type,後製品 工程type]) = ごちょごちょやって求めて
#        end
#        @change_time( [前製品 工程type,後製品 工程type] )
#     end
#   
# 
# 
# 
#     UbeProduct[]
#     UbeProduct 製品名、ロットサイズ、抄造機、乾燥
#     UbeOperation unit time  where 抄造機,抄造 type
#     UbeOperation unit time  where 乾燥機+乾燥 type
#     UbeOperation unit time  where 加工,抄造 type# 
#
#  
# 
#
#  
# 
#
#  
#==現場との相違
#1. ラウンド当りのロット数 :: 5つ以上続いていることもあり
#2. 同じ銘柄の乾燥は 切り替え5分ではなくマイナスになっている。
#
class Ubeboard

  #制約条件
  # 1. 工程間の時間に制限がある。
  #    1. 抄造 養生間は 72時間以内
  #    2. 養生 乾燥間は 最大24時間
  #    3. 乾燥 加工間は 最短24時間
  #
  # 2. 切り替え時間
  #    1. 同一品種間でも銘柄が異なると切り替えが長くなるものがある
  #    2. 特に長い切り替えの場合は指示書に明記する
  #  
  # 3. その他の条件
  #    1.製造数
  #      2. LiPS製造数に不良率を加味して製造立案する
  #      3. 養生庫は23室。どの養生庫かによって製造数変わる。
  #      4. 半端が出たら、1ロット増やし、最低数(700)を作る
  #      5. 同一品種は連続5lotまで。
  #    2.抄造
  #      1. 東抄造　ｳｪｯﾄﾌｪﾙﾄ15万枚以上使用時は、Ｓ１は生産できない
  #    3.養生
  #      1. 養生時間40時間だが、38時間にまで短縮OK
  #    4.乾燥
  #      1.乾燥後の24時間の後置き（3×10、3x6製品は後置き不要）
  #      2.同一銘柄のときオーバーラップ可能？
  #
  #
  # 4. 定期的保守
  #    毎日行うもの、毎週行うもの、ある品種の後で行うもの、稼働時間で行うものがある
  #    1. 毎日行うもの 東西抄造で酸洗を行う
  #    2. 毎週行うもの 毎週水曜に加工にて予防保守を行う
  #    3. 品種固有　　 12高級、15高級条件のあとは、サラン替を行う
  #    4. 稼働時間によるもの
  #         抄造時間  稼働時間1000時間で、ﾌﾟﾚｽﾌｪﾙﾄ取替を行う
  #         抄造枚数　18万～20万枚生産後、ｳｪｯﾄﾌｪﾙﾄ替えを行う
  #         乾燥枚数　140,000枚で刃物替
  #         
  def reguration ; end

  #===アルゴリズム argorism
  #1. 各工程毎に割り当てていく
  #2. 1ロット毎に割り当てていく
  #3. もっともタイトな工程(乾燥)をまずうめ、残りの工程を割り当てる
  #
  #==== 1.工程毎
  #この方法での問題点。
  # 1. 養生と乾燥の間が開きすぎたときの調整が十分できない。
  #    養生自体は遅らせればよいのだが、抄造を遅らせることが難しい。
  #    既に他のロットの抄造が割り当てられているから。
  #
  #===3. まず乾燥
  #実装を試みていない。
  #  抄造、養生などが入る余地が無かったときなどの処理が思いつかなかったため
  #  
  #  
  #==== 2.ロット毎
  #ということで、この方法で進めている
  #===具体的な方法。
  # 1. 仮に割り当てる。
  # 2. 養生-乾燥、抄造-養生の時間に問題が有ったらシフトする。
  # 3. 仮時間を決定したらその時間で割り当てる
  #
  #この方法での課題
  # 1. 切り替え時間、保守の決定には 前の品種・条件が必要。← UbeSkd.pre_condition に残す。
  # 2. 月度初めのロットでは pre_condition がない。← 前月分の取り込みは、必要なら完了も
  #
  #この方法に限らず課題
  # 1. 養生庫の決定は、空いた順とした。→ 残生産量に対する配慮が欲しい
  # 2. LiPSの順のままだと、抄造、乾燥の代替工程のバランスが悪い。→ 初期化にL4組み込もう
  #
  def argorism ; end


  #==システムの初期化
  module Init
    # /opt/www に rails -D mysql msdn 作成
    # mysql ユーザ msdn 作成し、DB msdn_{test,development,production} 作成
    # grant all PRIVILEGES on msdn_branch.* to msdn;
    #　　　MySQL DB 管理者は root pass は eh2
    # Lighttpd + fastcgi にするつもりであったが、断念
    #   Lighttpd では .htaccess によるアクセス制限を働かせるのがわからない
    #   fastcgiが動かん、、、
    # 
    # Apach+fastcgi もうまく動かない。。。
    # 
    # で、思い出した、passenger 
    #  http://redmine.jp/tech_note/apache-passenger/　で解決
    # 
    def server
    end

    #== 1. DB 作成
    #===MySQL初期化
    #     http://centossrv.com/mysql.shtml
    # 　　　　/etc/mysql/my.con
    # 
    #     ただし、default-character-set = utf8f を設定すると、文字化けた。。。
    #     mysqlの設定及びdatabase.ymlのutf-8指定をコメントアウトした
    # 
    #     しかしこれだと、mysqldump が文字化ける
    #   解決
    #     /etc/mysql/my.cnf の default-character-set = utf8 がコメントアウトされてた    # 
    #
    #  DB作成
    #    mysql ユーザ msdn 作成し、DB msdn_{test,development,production} 作成
    # 
    #    RAILS_ENV=production rake db:migrate
    # 
    def database
    end

    #DBのバックアップ
    # ~/bin/backup.shを毎日 23時過ぎにcronで起動している
    #  /home/test2/MSDN に /usr/bin/mysqldump にて書き出し、/bin/bzip2 している
    #  毎週日曜日には ftp://ug8s-dzw:ehr2648@netftp.asahi-net.or.jp/homepage/Farm/Message に送っている。
    #
    def backup; end

    # 2. マスター登録
    # 　　User, UserOptin, UbeProduct, UbeOperation,UbeChangeTime,UbeMeigara,UbeNamedChange
    # 
    #     Ube*　はウベボードトップ画面からCSVでUploadできる。
    #     User,UserOption は fixtures にて入れるのがよいか
    def master
    end

    # 初期データ登録
    # 前月分のデータを登録する。
    #   製造番号、養生庫、稼働時間を引き継ぐために必要
    # fixture として、ube_plans.csv, ube_skds.csv を用意し、読み込ませた後、
    #   RAILS_ENV=production ./script/console して、
    #   skd=UbeSkd.find(1)
    #   skd.ube_plans = UbePlans.all(:conditions => ["....."])
    # もしくは、ube_plans_ube_skds.csv も fixture する
    #
    # ube_plans.csv に必要なplan
    #   抄造、乾燥、加工の５工程を最後に実施したロット
    #   養生庫2-24を最後に使ったロット
    #   仕掛かりと未実施
    def initial_data
    end
  end

  #===工程の概要 operation
  #抄造、養生、乾燥、加工の４工程からなる。
  #  抄造、乾燥は2ライン（東西抄造、原新乾燥）がある。
  #  品種によって１ラインしか通せないものと4種類のラインの組み合わせができるものがある、。
  #  養生は24庫あり、そのどれもが同じ条件であるが、3種の大きさがある。
  #  製造は養生庫にいっぱいになる数量を１ロットとする。
  #
  def operation; end

  #品種・製品・銘柄
  #製品は、品種、製品、銘柄という３階層になっている。
  #* これらを、UbeOperation , UbeProduct , UbeMeigara で管理する。
  #
  #品種の登録に当たってはさらに UbeChangeTime への登録も必要。
  def production ; end

  #保守 
  #保守は基本的には自動的に割り付けられる。
  #
  #割付は「保守要否評価」 Function::UbeSkdHelp#maintain_time にて行われる。
  #- 割付自体はプログラムで判断されるが、それをどう表現するか、は UbeProduct 
  #  に登録する。
  #- 所要時間は UbeOperation に登録する
  def maintain; end

  #切り替え時間
  #1. 切り替え時間は UbeChangeTime に登録する。
  #2. 長い切り替え(UbeSkd::ChangeTimeLimit 以上)は作業指示書に明記する必要が有る。
  #     「UbeNamedChange に有るものは」とできないのは、UbeNamedChange への登録で
  #     「次の品種が何であっても」「前の品種が何であっても」という指定が有る。
  #     このため、同じ品種のロット間のインタバルで記名が入ってしまうため。 
  #3. 切り替えの表示名は UbeNamedChange に登録する。
  #4. 複数の切り替え名がダブる可能性が有る。そのときの表示優先順も UbeNamedChange に定義する。
  #      長い切り替えは、その品種に替る時とその品種が終わったときとに
  #      発生する可能性がある。前後品種の組み合わせによっては、前品種の
  #      後始末と後品種の準備の両方が記名切り替えになる事が有る。
  #
  #記名切り替えの増減はプログラムの修正が必要 とマニュアルには記述してあるが、
  #このModelを作ることで、UbeSkd::ChangeTimeLimit 以上の切り替えであるなら
  #Modelへの登録を行うだけで出きるようになった。
  #  これで工数o稼ぎましょう。
  def change_time ; end

  #ロット間のインターバルを求める。
  #===次の工程の時間の決定
  #====抄造、乾燥、加工の場合(養生以外)
  # これは次の中で一番遅い時間以降の空き時間
  #  1. 前の工程終了時間＋次の工程に移動するのに要する時間 
  #  2. 次の工程の前の品種が終わった時間 + 切り替え時間   
  #  3. 次の工程の前の品種が終わった時間 + 保守に要する時間 
  # 
  # ここで「前の品種が終わった時間」は工程によって考え方が変わる
  # 1. 抄造、加工
  #     最後の１枚が工程を出るとき。(plan_to) 開始時間＋所要時間(Unit_time * 製造数)
  # 2. 乾燥
  #     保守と切り替えで変わる
  #  2-1. 保守
  #         最後の１枚が工程を出るとき。(plan_to)。
  #         乾燥の保守は30分、刃物替えのみ。終了を待たず切り替えを開始してよい
  #  2-1. 切り替え
  #         最後の１枚が工程に入るとき。搬入終了(plan_end)
  #         ただし、保守も入るときは、保守が開始できる工程終了まで待つことになる。
  #=====移動時間
  #  transfer 結果開始可能時間は transfer_time で得られる。
  #  切り替え時間 は UbeChangeTime を元に、UbePlan#change_time で得られる、
  #   これをさらに UbeSkd#change_time で受けて、「長時間の場合は明記する」対象かどうか、を判断し、
  #   かつ　UbeSkdHelpの各methodで用いる、hozencode形式にする。
  #=====保守に要する時間 
  #  maintain_time が返す。
  #====== Tag DryOverUp(～11/9/19)までの実装  
  #    工程を割り付けたとき呼び出し、その工程、経過時間、曜日などから、
  #    次のロットの前に保守を入れる必要があるかどうかを返す。
  #====== Tag BR_Maintain(11/9/19～)からの実装  
  # 「次のロットが終わると*＊時間を越える」ようなら保守する、という次ロットの情報が必要になった
  #  ので、change_time の評価と同じく、次ロットの検討時に行う事に変更する。
  #
  #  これらの比較を行いどれを採用するか決めるのは temp_assign_maint 、
  #  これは temp_assign_maint_plan から呼ばれる。
  #  temp_assign_maint_plan はこの戻り値以降の空き時間を確保する。
  #
  #  assign_temp_and_real 
  #        -- temp_assign_all_plan 
  #                  -- temp_assign_maint_plan 
  #                                  --+-- temp_assign_maint
  #                                    +-- temp_assign_plan
  module Interbal
    def maintain
    end
  end
end
__END__

#==To build the guides:
#* Install source-highlighter (http://www.gnu.org/software/src-highlite/source-highlight.html)
#* Install the mizuho gem (http://github.com/FooBarWidget/mizuho/tree/master)
#* Run `rake guides` from the railties directory
#
#

#

#$Id: ubeboard.rb,v 1.13 2012-10-16 08:49:11 dezawa Exp $

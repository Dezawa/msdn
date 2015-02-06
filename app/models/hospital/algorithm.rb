# -*- coding: utf-8 -*-
__END__

コストでソートして低い方から選ぶが、
  j準夜、深夜 のコストの算出は
     tight_roles,勤務残  とも、 そのシフトでの か 夜間勤務計を用いるかぐちゃぐちゃ

candidate_combination_for_night_selected_by_cost
   candidate_combination_for_night(day)  # 準夜深夜の分をまとめて候補を作る
      candidate_for_night(day)
        short_role
        assinable_nurces_by_cost_size_limited # (sft_str,day,short_roles_this_shift )
          assinable_nurces
          limit_of_nurce_candidate
          if daytime nurce.cost
          if night   gather_by_each_group_of_role(as_nurce,sft_str,short_roles_this_shift))
             nurce.cost(@night_mode ? :night_total : Sshift1,tight_roles(sft_str))
   cost_of_nurce_combination # 勤務残もタイトロールも 準夜深夜を使わず 夜勤計 を用いる

assign_patern
  assign_patern_if_possible   失敗 :cannot_assign_this_patern
     assign_test_patern
       Nurce#long_check
        long_check_sub
           check
     nurce_set_patern
  long_check_later_days
  avoid_check
# SHUNIN_SERIAL
#  主任への1クール割り当てが同じ日にならないように
#  1人目の終了日を次の人の探索開始日とした
# 
# KANRI_JUNYA_ORDER_BY_YAKINSUU
#  主任への1クール割り当て順を、希望日に夜勤が多い順にした。
# 
# CHECK_EACH_DAY_BEFORE_LONG_ASSIGN
#  一度に複数日をアサインするとき、各日の0123勤務が過剰になっていないか調査する。
#    つもりなのだが、足りないroleがあると追加してしまうことだなぁ、、、、
# 
####　そこで、総当たり的に行うこととした
# Algorithm-1
#
# 各日の割り当てを再帰で行う。
#   その日、そのshiftが可能な看護師の集合から、必要な人数の組み合わせを作る。  
#   組み合わせ一つずつ
#     割り当てを試みる。  
#     その日の割り当てに成功したら翌日の割り当てを再帰で行う
#      再帰が失敗で帰ったら次の組み合わせを試みる
#
#   翌日が無ければ成功で帰る
#   割り当てが出来なかったら失敗で帰る
#   
# 全ての再帰は直接 Nurce#shiftを触る
=======
NurceOnlyFinal
  A: 夜勤を月末まで割付け、その後で日勤を割り付ける
  B: 割付候補はcostの安い順に各日各shift2～3組に絞る
  C: 各候補は「翌日以降の結果に責任はないが、当日の結果には責任を持つ」ものに絞る
    すなわち、 
      C-1:看護師の重複が無い
      C-2:要員数・資格数を満たす
      C-3:その割付で制約に抵触しない
  D: C-1 のために、夜勤の割付候補は「shift2とshift3の看護師組み合わせ」で行う
  E: この組み合わせは次のステップで作る
    E-1: その日shift2割付可能な看護師を選び、cost+αで並べ安い方からshift2,3必要人数合計*β選ぶ。
    E-2: shift2必要人数のcombinationを作る。=> comb2
    E-3: shift3についても同じくcomb3を作る。
    E-4: comb2,comb3のProductを作り、看護師の重複しているものを外す。
    E-5: costで並べ、3つを選ぶ。
  
  F: その日割付可能な看護師の選び方
     まだ割り付けられて居らず、まだ足りないroleのどれか一つは持っており、そのshiftを割り付けても制約違反にならない。
  
  G: 望ましい勤務パターンの実現
     shift2を割り付けるとき、220330、220，２ という割付が可能で、この順で好ましい。
     そこで、2を割り付けるとき、これらの割付が可能かどうか調べ、可能なら割り付けてしまう。
     shift3のときは 330,3 の二つについて行う。
  
  H: 残りrole数、勤務可能数の計算高速化(各看護師と全体の)
     これらはshiftの割付ごとに変わっていく。この計算は全員の全日にちの割付状態をなめる必要があり計算コストが掛かる。
     その軽減のため、割付開始時に計算した後は、割付ごとに修正する。
     戻りのために、各shiftの割付(試行)開始時に状態をpushし、割付失敗したらpopする。
  I: cost計算の高速化。 まだしていない。

#####
  1) costについて
    勤務可能な日数が多いと安く、少ないと高い。
    必要なroleを沢山持つと高く、少ないと安い。
  2) E-1のβ: 今は1.1を採用。最終的に3組しか採らないなら、1倍で良いかもしれない。
    ただ、パートや准看護師を考慮する版にするときは要注意。
  3) E-2: 出来たcombinationのサイズはやや大きいが、ここでは数を減らさない。
         その代わりに、候補看護師数を絞る
      必要なcombination数はshifft2,3の選ばれた看護師の間の看護師重複具合や必要人数によって変わるが、
      その解明をまだ行っていないから。
      これを減らせると、Productサイズが減るので高速化につながる。
  4) E-3,4:rubyでは、これは以下の方法に比べる2倍くらい掛かり、ちょっと損。
     comb2から順に一組抜き出し
     shift3の割付可能看護師群からshift2に使われた看護師を除き
     残った看護師でshift3のcombinationを作る
     comb2の全候補について行って「Productから重複を外した」ものを作る
     
     この損具合は、shift2,3の必要人数が増えるほど大きくなる。
     
   5) G: このパターンはcomb2の全看護師について調べる必要がある。4人居れば12通り。
        30秒で終わるケースでは、前の日に戻ること無しに割付が終わるが、この12組のパターンについては戻りが発生している。
  
   6) I: Eを行うとき、E1で選ばれた人数分、E5で組み合わせの数*人数分 のcost計算が行われる。
       例えば20人可能で、8人選んで、4人の組を作ると、
       20 + (8*7*6*5)/(1*2*3*4) * 4 = 300 回。始めの20回で必要なコストは計算済みなので、うまくメモ化できる
       と高速化につながる。
          あ、sortの時の比較のたびにやるか？ 
   
  8)  重要な(残り少ない)roleを持つ方が高い
  9) Bについて。
    割付の破綻は月末に起きる。そこからツリーをたどって原因のある日まで戻るとき、
    「候補の数」の「戻る過程のシフト数」乗という膨大な候補の評価が行われる。2日戻るにも10分オーダーを超える。
    30秒程度で割付が終わる例では一度も日を戻ることは無い。
  10) Cについて
    候補数が少ないので、当日の割付すら出来ないものがあると破綻する
  11) Dについて
   「shift2の組み合わせ」の候補と「shift3の組み合わせ」の候補のセットでは以下で良くない
    候補の数を大きくしないと C-1が満たせなくなる。
    候補を多くすると、組み合わせ数が増え時間が掛かるようになる。
  12) E-1のα: costで並べると(costが安い)重要でないroleを持つものばかりが残り、必要なロールが揃わない恐れがある。
    そこで、持っているroleの組み合わせでグループ分けし、それぞれの群の中で安い順に満遍なく選び、必要人数抜き取る。

tag HP140512
勤務計には看護師が延べ 527人日必要なところ余裕は26人日です。計算時間が掛かるかもしれません
夜勤計には看護師が延べ 217人日必要なところ余裕は12人日です。計算時間が掛かるかもしれません
夜勤計にはリーダーが延べ 62人日必要なところ余裕は10人日です。計算時間が掛かるかもしれません
準夜には看護師が延べ 124人日必要なところ余裕は14人日です。計算時間が掛かるかもしれません
深夜にはリーダーが延べ 31人日必要なところ余裕は9人日です。計算時間が掛かるかもしれません
準夜にはリーダーが延べ 31人日必要なところ余裕は9人日です。計算時間が掛かるかもしれません

おかしい、できなくなった。。。。
  わかった。
  夜勤トータルが勤務トータルより大きくて夜勤しきれない人がいた
   #  5F
   #            要員余裕／人日
   #        看護師         リーダー     HP_Logging   UBR_HOSPITAL  HOSPITAL_Shift1 HP_CostByNightTotal   
   #     勤務  準夜 夜勤 夜勤 準夜 深夜   HP140512   HP140506      HP_shift1_2
   #      26    14   12   10   9    9    NG
   #      31    14   12   10   9    9    NG          NG shift23-29
   #      36    14   12   10   9    9   NG shift1-30                NG shift1-30
   #      38    14   12   10   9    9   NG shift1-30                 44.0秒 
   #      39    14   12   10   9    9    48.0秒                      37.4秒           149.2秒
   #      39    14   11    9   9    9                                 NG              150.9秒  
   #     勤務  準夜 夜勤  夜勤 準夜 深夜
   #  
   #  HOSPITAL_Logging:HP140512では、shift1の割付に月末で失敗している
   #  HOSPITAL_Shift1
   #       shift1の候補数を減らし、戻りが早くなるようにしてみる。
   #  
   #  3F          要員余裕／人日
   #        看護師         リーダー      HOSPITAL_Shift1   
   #     勤務 夜勤 準夜  夜勤 準夜 深夜  HP_shift1_2
   #       48   23   19     1    4   4     17.7秒
   #       48   15   15     1    4   4     19.7秒
   #       48    6   10     1    4   4     18.7秒
   #       48    2    8     1    4   4     14.2秒
   #       48    2    8     1    4   4     16.1秒
   #       26    2    8     1    4   4     16.1秒
   #       21    2    8     1    4   4     15.8秒
   #       16    2    8     1    4   4     NG

5F
          要員余裕／人日
      看護師         リーダー       HP_CostByNightTotal   
   勤務  準夜 夜勤 夜勤 準夜 深夜  
    46    14   15   10    9    9    27.0秒
    39    13   14    9    8    8    28.8秒
    39    13   13    8    8    8    27.4秒
    39    12   12    7    7    7    61.8秒
    39    11   11    6    6    6    28.5秒
    39    10   10    5    5    5    NG
    39    10    9    6    6    6    NG
    39    10   10    6    6    6    NG
    39    10   11    5    6    6   148.4秒 <- あとでここの1日目の割り当てを 比較しよう
    39    11   11    5    5    5   184.8秒
    37    11   11    6    6    6    28.3秒
    35    11   11    6    6    6    28.1秒
    33    11   11    6    6    6    28.1秒
    31    11   11    6    6    6    28.7秒
    29    11   11    6    6    6    28.8秒
    27    11   11    6    6    6    28.8秒
    25    11   11    6    6    6    36.8秒

 
  ＃＃ HOSPITAL_Shift1::HP_shift1_2 を UBR_HOSPITAL にマージした

     ＊＊ 希望を入れると「38   12   14    10   9    9」では埋まらない
  
HP_Hope
  希望入力画面が、直前の割付結果と異なるようだ。その修正
  L2,L3 が '_','_' になってしまう

  勤務コードの選択枝に間違いが入っていた。なおしUBR_HOSPITAL にマージした

HP_CostByNightTotal
  Shift2,3の候補のsortにつかうcostに、Shift2,3でなく夜勤トータルを
  使うようにする。
   UBR_HOSPITAL にマージした  tag HP_140516

HP_SubNurce
  準看護師を無視していたのを、取り込む。
  正看護師 min ＋ 準看護師 max == の正看護師 max ＋ 準看護師 min の人数が必要とする。




 Nurce#shiftを触る

# 再帰に当たって前の状態に戻すために、Nurce#shiftをdupしておく
# 
# Algorithm-1-2
#   1の割当のやり直しが長い。ocmbinationが長いためだろう
#   長割付の優先が外れないので、そこでトラブってる。
#   長割付も再帰に入れる
# 
# 
# Algorithm-1-3
#   長い割付が先の方で「看護師人数足りているが、ロールが不足」という事態を
#   招いた場合、原因となった長い割付を取り除くまでに何度も繰り返しが行われる
#   
#   長い割付にあたって、shift2,3については、ロールのチェックも行う
# 
# 
# Algorithm_1_4
#   割付可能な看護師では必要なroleが足りない場合はすぐ戻る
# 
#  *** 長い割当を行うと、後ろの方でうまく行かなくなるというケースが色々出てくるようだ
# 
# 
# 
# Algorithm_2
#   長いo割付を3日までにした。それでも14日までだ。一晩でも終わらない。
#  ここで凍結。
#  tag LONG_3DAYS
#  cp log/development.log log/tag_3days
# 
#  主原因はリーダの人が足りなくて、13日で使い切っていたため
#  
#  が、、、 
#  3日までにすると、3日に0が重なり、人がたりなくなりがち。
# 
# Algorithm_2_1 
# tag DAYTIME_AFTER_NIGHT
#    1. longcheckで0の数を確認する
#    2. 後半夜勤が割り付けにくくなる。
#        前半１が続く人、逆に前半に夜勤を使いきってしまう人がいる。
#        このため、後半選択肢が狭まり割付困難に
#           evaluationで夜勤数割付の配点をもっと高くする
#           を試したがあまり効果はでなかった
#    3. 勤務 2,3はリーダがダブってアサインされにくくなる様にする 
#        combinationを場合分けし、夜勤の場合はリーダが一人だけ、
#        というu組み合わせを先に出すようにした。
# そこで
#  夜勤をまず割付、その後日勤を割り付けるようにした。  
#  制約が厳しい夜勤を行うことで、日勤に取られて人不足という事態が無くなると同時に
#  戻るときに日勤分が無くなるので早くなる
#    
#   しかしこれでも余裕が少ない場合は収束しない 
#    
#    
# Algorithm_2_2
#  評価を看護師単独で行うのではなく、看護師の組み合わせに対して行う
#    夜勤の場合
#      リーダ：無しは削除、一人が高配点、増えるほど配点下がる
#    
#    日勤の場合
#    
#    共通
#      ? 看護師のロールの合計が、各ロールでバランスしているものが高配点
#      ? 看護師のロールの最大が少ないものが高配点
#      ? 条件の厳しいロールが少ないものが高配点
#    
#     ??? 一日分の評価で月度の評価は適するのか？
#    
#      ! アサイン可能残りroleの合計を管理し、 
#        残り少ないものの消費が少ないものの配点を上げる 
#    
#        組み合わせの看護師の role の累積 S
#        アサイン可能 role の 残り数      R
#      この二つで評価する
#          R の少ない role の S が小さいほど良い
#
#      tag EVALUATE_COMBINATION_OF_NURCE
#
#
# Algorithm_2_3
#   shift3を割り当てることで、shift2の条件にあう看護師がそろわないことが
#   ある。このとき、同じshift3で延々とshift2の組み合わせを試している。
#
#   このようなshift3ははじめから候補から除く。
#
#　　つまり
#　　shift2 用の看護師の組み合わせのarryと
#　　shift3 用の看護新の組み合わせのarryを用意し
#　　そのproductのうち、看護師が重複しないものだけ残す
#　　その、組み合わせの組み合わせの一覧から、順次試す。
#
#　　これで非常に高速になったが、1の割付ができない場合に、そこまで
#　　戻れないため、NGだ、、、
#
#　　2,3だけでなく、１も入れてやるべしや
#    2/1のshift1の可能看護師の抜き出しが少ないみたいだ。なぜ？
#
#    tag COMBINATION_OF_COMBINATION
##
# Algorithm_2_4
#    shift 1も対象にした
#　　product が巨大な配列を返すので、メモリが不足か？
#　　組み合わせの組み合わせを返すのが遅い。
#
#　　配列を返さないようにするべきや
#
#    tag COMBINATION_OF_COMBINATION_123
#　
#  とても早くなりました。
#    が、
#    「組み合わせの組み合わせ」の優先付けが出来なくなりました。
#     shift2,3については組み合わせを作り優先度付けを行う事を試す。
# 
#        長割1　1 , 2 220 , 3 330 
#        長割2  1 110220330,  2 220 220 330, 3 330 330110
#
#　リーダ8人
#        長割1     長割2
#　5月   104sec
#  6月
#　2月　　40sec    225sec
#
#　リーダ7人
#        長割1     長割2
#　5月   sec
#  6月
#　2月　 sec    sec
#
# Algorithm_2_4
#　shift2,3の「組み合わせの組み合わせ」については評価の合計点で
#  sortした。より高速,,,でもないな、長割り1では遅くなった
#
#        長割1     長割2
#　5月   119sec
#  6月    93sec
#　2月　　70sec     48c <- 225sec
#
#   tag COMBINATION_OF_COMBINATION_USE_BLOCK_SHIFT23_OPTIMIZED 
#
# リーダ9人
#        長割1     長割2
#　5月   102sec
#  6月   125sec
#　2月　　62sec     48c <- 225sec
#
#  productを作ってしまう分か、リーダが増えるとかえって遅くなるときもある
#
# 戻してみたが、optimizeするほうが早そう
# 2月 37 、5月 100、6月 178sec 
#
# 評価を少し変えた
#   cmb2とcmb3の評価の合計ではなく、cmb2+cmb3のnurce全体の評価とする
#   
# 2月 46 、5月 131、6月 103sec 
#      
# リーダ8人で5月を割り付けるとき、31日が割りつかない。
# まだリーダが空いているのに。なぜか？ <= @longestの書き込みミス
#      
#      
#      
#######
# ひとまずfix版
#  tag COMB_OF_COMB_WITHOUT_OPTIMIZE 2013/5/24
#
#  この版での繰り返し数　333　302.sec
# 
# 1. shift1,2,3の看護師群候補を作る
# 2. shift2,3,1の順で割り付ける
#
# 3. 看護師群候補はshift毎に作りそのproductのうち、看護師が重ならないものだけ使う
#    productを作ってしまうととても非効率なので、ループで回して作る。
#    
# 4. 各shiftの看護師群は、その日のshiftで必要な看護師人数roleを満たすものだけを用意する。
# 
# 「最適化なし」は　1. の￥での最適化を行わない、という意味。
#    ここで最適化を行うにはproductを作らねばならないのでやめる。
#    ただ、shift2,3の組み合わせについては、行う。
#
# 最適化は評価結果に従って群の順を並べることで行う
#    割付不可で戻るのはrole不足がほとんどなので、逼迫roleの消費が少なくなる事が高評価
#
#     
# 4.での最適化
#    Hospital::Assign#nurce_combination?_by_remain で残roleに着目した   
#    評価でソートされた、看護師の組のリスト(Array)を得る
#    
#    残roleに着目した評価：はその組が消費するroleとそのroleの逼迫順の積の和で決める
#    
#   Hospital::Assign#evaluate_combination
#     看護師群の各看護師が持つroleの集計 と 逼迫role順(i)で求める
#     Σ(i) (role(i)*role残) * 10**i 
#    
#######
# nurce_not_assigned_with_evalは要らんじゃろ版
#  tag COMB_OF_COMB_WITHOUT_EVALUATE_NURCE 2013/5/24
#
#  この版での繰り返し数　201
#             繰り返し201回, 評価436回 70.788855秒
# ** assinable_nurces は nurce_not_assigned_with_eval を使っている。    
#    しかし、それとは係りなく　evaluate_combinationで再sortされているから、
#    evaluateの負荷のないnurce_not_assignedでよいはず。
# かつ
#   nurce_not_assignedにて、不足roleが少なくとも一つあるやつ、を盛り込んだ
#    
# 新バージョンへの検討    
#   評点
#    逼迫ロールの消費が少ない組み合わせ
#    逼迫ロールの残量が多い看護士⇒逼迫ロールの残量の最小値の最大値
#    
#    ⇒
#    逼迫ロールの消費量が少メンバーの逼迫ロール残量の最小値の最大値が大
#
#
#    逼迫を順番ではなく割合で表す。いや、数の絶対値の方が良いのでは
#      割り当て可能残数 - 割り当て必要残数 margin_of_role {[role,shift] => 余裕 }    
#    
#    逼迫ロールの残量が多い看護士⇒逼迫ロールの残量の最小値の最大値
#                   max_of_min_of_remain 
#    
# 割り当てたい人は誰か？ [role145が逼迫している、として]
#   次のrole保持者を出来るだけ残したい
#    [1,4,5], [1,4], [1,5], [0], [4], [5] 
#       6       5      4     3    2   1  <- point。小さいほう優先割付
#   
# 看護師の組み合わせとしては？   
#     145  14  15  45 1  4  5  - 
# 145  12  11  10  9  8  6  5  2
#  14 ---   X   7  X  X  X  4  X
#  15 --------  X  X  X  3  X  X
#  45 ------------ X  1  X  X  X 
#   1 --------------- X  X  X  X
#   4 -----------------     X  X
#   5 ---------------------    X
#       
# この評点でグループをsort。これに看護師のrole残数を加味する。
#   加味：候補(1) max_of_min かな。。。。
#  
# 組み合わせの評定はいつ再計算すべきか
#   逼迫roleの組み合わせ    再帰の日毎
#   看護師のrole            固定
#   
#  逼迫ロールの組み合わせ、看護師roleで評価Tableをあらかじめ作っておける
#  
#  Hosiptal::Need.combination3 : 最低一人はほしいroleの組み合わせ
#  Hospital::Nurce.cost[tight_top_3_roles][role_id] => point
#  
#  ## costの計算のとき、複数roleを消費する時にcostUpしていない
#  ## 必要看護師数の計算で、各shiftごとにしか行っていないが、3shift合わせて、
#  ## を見ることで早くできないか 変わらんかった
#  ## 夜勤、日勤が偏る。cost計算がおかしいかも

TIGHTNESSの詳細分析 tightness_feb
1 2/3のassign shift2でNurce44,49 なぜ220330,220が入らないのか
2 やりなおしの2/3、3:1falseとなっているのはなぜ？
3 2/4:2 2の使用数の違う38,39のcostが同じなのはなぜ？
4 2/4:3 3の使用のない37,42,43,38,39でcostが違うのはなぜか
コスト計算見直し必要だな

# TIGHT_ROLE_IS_FIXED版
    Assign#tight_rolesが二つ定義されていて、正しく無い方が使われていた。
    が、
    tight、逼迫 というより、ロール残でまだやっていた。
    これでテスト環境（msdntestold)では1分以内となったが
    msdntestのproductionでは2月がtimeout。
      前月空今月希望あり  だと月初の割付を間違える模様。
      解析してみる  
       tightness の計算がおかしい。

# tag SEMIFINAL版
    long_check_later_daysでtoo_many?が0で帰ってきたとき、
    roleが足りていなければ失敗 という枝刈りを復活させた。
       220330を割り当てたとき、既に希望で入っていた3との組み合わせで
       roleが足りないことが起きると、220まで戻る前に時間切れとなってしまう。
#####
tag SEMIFINAL版 ToDo
　Timeoutしたむねの表示。   
  Timeout時間のユーザ指定
      
  組み合わせ禁忌の実装
  逼迫roleでcost計算していたつもりが、残roleで行っていた。
      これは直すべきや？ 
      逼迫role計算に必要な margin_role の更新がちと厄介そう

  夜勤が続く。330220330のパターンが多い。
     このとき、11111、日勤5連続も併発する。
     これが良いのか悪いのか。

     原因
       3を当てるコストが低い人は2を当てるコストも低いことが普通。
       今は3の残数が減っても2のコストが上がらない

     解決策案
       cost計算に可能夜勤残数を考慮する
       Nurce::Costの等高線をもっと立てる←筋違いかも

  出張は Nurce#shift_remain に正しく反映されるか
    あら、日勤扱い(縦も横も１ になってる）




######## HOSPITAL_SPEEDUP_6 ##  高速化やり直し #################
# 病棟看護師数が増えると、nCm が巨大になるため、渋滞停止。
# 
# shift 1 については nurce_combination_by_tightness を作らないことにしよう
# アサイン可能な看護師の数を、優先度順で20人程度に絞る
# shift2,3も、top 50位に減らそう
       SelectedMax (20) にしてみた


# 
# 高速化準備作業
#  #assign_month の下部構造を見る
# 
#  assign_month
#    + assign_days_by_re_entrant
#    |  + assign_days_by_re_entrant123(day)
#    |  |  + short_role(day,3,true)   # この日のこのshiftの看護師の必要数と不足role
#    |  |  + short_role_shift_of(day) # 看護師の必要数
#    |  |      ここまでlogに出て止まる。
#    |  |  
#    |  |  + nurce_combination_by_tightness # shift 1,2,3 各々の看護師組み合わせの配列を作る
#    |  |      + nurces.combination(need_nurces)   9Ｃ20 ->  9C30 -> 
#    |  |           sort_by{  cost_of_nurce_combination  }
#    |  |      
#    |  |  + combination_combination_for_123{ # shift 2,3 の組み合わせの組み合わせを一つずつ作る
#    |  |  | {
#    |  |  +   assign_shift_by_reentrant
#    |  |  |     + long_plan_combination  
#    |  |  |     |  { 
#    |  |  |     |    assign_test_patern 
#    |  |  |     |      + nurce_set_patern
#    |  |  |     |      + long_check_later_days
#    |  |  |     |      |    + too_many?
#    |  |  |     |    assign_patern  
#    |  |  |     |    case
#    |  |  |     |       assign_day_by_re_entrant123
#    |  |  |     |       assign_shift_by_reentrant
#    |  |  |     |   } 
#    |  |  | } 
#    |
#    + restore_shift(@nurces,day,@longest[1]) if @longest
# 
#  nurce_combination_by_tightness が巨大過ぎるのが原因
#    conbination.select.sort   select で 3C30、2C30、10C30 が残る
#       3C30 = 30*29*28/6 = 140*30 = 4060
#       2C30 = 30*29/2             =  435
#      10C30                       = 7.3 * 10^25
# 
#       3C20 = 20*19*18/6 = 1140
#       2C20 = 20*19/2    =  190
#      10C20 =            =   6.7 * 10^11
# 
#(1) shift 1 については nurce_combination_by_tightness を作らないことにしよう
#(2) アサイン可能な看護師の数を、優先度順で20人程度に絞る
#(3) shift2,3も、top 50位に減らそう
# 
################ 制限数をもっと絞ってみる ##########
# HOSPITAL_SPEEDUP_7
    看護師候補数をさらに絞った
    shift2,3は 必要数2,3の合計 *1.5
    shoht1  は 必要数の        *1.5

    絞ったときに、ロールをたくさん持つ人はcostの関係で削除されやすいので
    持っているロール毎に送別して混ぜてから絞っていたが、そのコストも下げるため
    これより人数が少ないときはその混ぜる操作を止めた。どうせ全看護師なのだから
# 
# 
################ 夜勤 ファースト 再び #############################

次のためには先に夜勤を済ませる方が楽かも
  日勤にパートや准看を入れる
  Ｌ勤の人を夜勤に組み込む
#############################
roles_shift などのshift を IntからStringに変更。
かつ、複数解を求めるようにした。
POLLING_RESULTS
ポーリングがうまく行っていない
#############################
Assignable Nurces are not enough になるとアボートする。

#### tag ASSIGN_MULT_TMP3 ###########
  MULTの1日めentryのdumpが必 ず出るように位置を変えた
> save_shift/restore_shiftの記録が汚染される様だ。clear_assignを入れてしのぐ
> assign_tight_daies_first や ready_for_day_reentrantがfalseで戻ってきたときの始末間違い
     次の候補に行かずに日勤割り当てに進んでいたため、combination作りでアボート
> long_check_later_daysで日勤要員を数えるのはshift1では不要なんで、shiftを引数に追加

  #####
  assign_month が assign_month_mult の5倍遅いのはなぜ？
  33_*** という所に日勤を入れて 331** となってしまうことがある
   ==> nurce.rb 1.1.2.81  日勤の Reguration に :after_nights 追加。


  ###
   MSDNTESTOLD 2月を行うと、ある程度MULTが溜まった所でまたすべて消えて FINEだけとなる。 
   logを見ると、途中から「1:2の割り当てであるにも関わらず月後半に0220330などがある」という
   状況がある。それが発生するタイミングでMULTが削除されている様だ。

   エラーで止まっていたプロセスの再起動による物の様だ。
      Delayed::Worker.max_attempts = 1 # リトライ回数
   によりそれは回避できそう。




 id           3 
 handler      --- !ruby/struct:Delayed::PerformableMethod 
    object: LOAD;Hospital::Assign
    method: :create_assign
    args: 
    - 1
    - 2013-02-01
    - 2
 locked_by   delayed_job host:www pid:984



#############################
POLINGさせるようにしたら、show_assignなどがやけに時間がかかるようになった
その解析
Processing HospitalMonthlyController#show_assign (for 192.168.1.5 at 2013-07-17 12:06:32) [GET]
*Assign.new
  Hospital::Busho Columns (0.4ms)   1mSHOW FIELDS FROM `bushos`
  Hospital::Busho Load (0.1ms)   SELECT * FROM `bushos` WHERE (`bushos`.`id` = 1) 
  CACHE (0.0ms)   1mSELECT * FROM `bushos` WHERE (`bushos`.`id` = 1) 
*@koutai3 = Hospital::Define.koutai3?
  Hospital::Define Load (0.1ms)   SELECT * FROM `hospital_defines` WHERE (attribute = 'hospital_Koutai') 
  Hospital::Define Columns (0.8ms)   1mSHOW FIELDS FROM `hospital_defines`

*@nurces = Hospital::Nurce.by_busho(@busho_id)
  Hospital::Nurce Load (0.1ms)   SELECT * FROM `nurces` WHERE (busho_id = 1) 
  Hospital::Nurce Columns (1.0ms)   1mSHOW FIELDS FROM `nurces`
  Hospital::Limit Columns (0.5ms)   SHOW FIELDS FROM `hospital_limits`

############## ASSIGN_MULT_OK0 /2013/8/15 ##############################
1)40 寺田輝子 
  40 _302201_3111__1_22031L1__11_1 で、:afternightsに引っかかる
  これは 2 が L になっているから。

  初めは 2。割付が終わり Monthly#restore_days で
     @shift.gsub!(/23/,"LM")    if     Hospital::Define.koutai3?
  を行い、L になったものが、次の周回で元に戻っていないため

   はて、consoleではそうならない

2)裏で進行中に クリア、割付 を行うと 待ての表示がでるが、その時の表示内容が変化する
    こいつだ
            if single
              save
              dbgout("HP ASSIGN return single is #{single} #{single == true}")
              return true if single == 1
            end
3)全部終わった所でチェックを行うと、表示中のcount0 のではなく、
  最後の count13 の物が評価される
    2)が原因だった。
#############################
Hospital::Kinmucode::From0123, To0123 の見直し

  shiftsでの
  表記 対応 横   縦
    0   0   1    1     休み系  公休、年休、代休、欠勤、、、
    1   1   1    1     日勤 1 会 会1  □ △ 4 会 会１
    2   2   1    1     準夜、L2
    3   3   1    1     深夜  L3
    4   1   1    0     出    イ１ H1 R1  J1
    5   2   1    0     管    イ２ H2 R2 
    6   3   1    0     イ３ H3 R3
    7   1   1   0.5    出/1  1/出  1/セ
    8   1  0.5  0.5     Z 
    9   1  0.5  0.5     G 
    A   1  0.5   0      Z/R Z/出 
    B   1  0.5   0      R/G 出/G

    ?   1   ?    ?      ▲ 遅 早 外

#########################
##
  (1)  1.1.2.50
  (2) COMB_OF_COMB_WITHOUT_EVALUATE_NURCE: 1.1.2.55]
  (3) 1.1.2.57  TIGHTNESS				
  (4) NURCE_COST_BY_SHIFT_REMAIN
  (5) TIGHT_ROLE_IS_FIXED
  (6) HOSPITAL_SPEEDUP_6
       (1)              (3)         **             **       (4)        
    繰返 評価
2月  235  454 TO    201  436 75  432 973 268-87  239 534 36 154 388 24
5月  135  322 180   699 1736 TO  182 478  81                306 596 159

        2月                  5月          5階病棟
     繰返 評価 秒      繰返 評価 秒
(1)  235  454   TO      135  322 180
(2)  201  436   75      699 1736  TO 
(3)  432  973  268-87   182  478  81
(4)  154  388   24      306  596 159
(5)   98  250   17       95  240  38    ∞
(6)             16                      75
(7)                      93  221  23    40


############### 解析 7/24
HP ASSIGN(580) 1:2 tight:145 [[49:162,37:70],[39:212,46:50],[49:162,44:133],[34:206,44:133],[39:212,44:133],[39:212,49:162]]
HP ASSIGN(580) 1:3 tight:145 [[37:70,48:162],[45:133,48:162],[48:162,44:163],[45:133,39:212],[45:133,40:212],[48:162,40:212],[48:162,39:212],[44:163,40:212],[44:163,39:212],[37:70,36:500],[45:133,36:500],[44:163,36:500],[39:212,36:500],[40:212,36:500]]

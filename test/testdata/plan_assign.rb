# -*- coding: utf-8 -*-
#

### 加工の保守,製造仮割付
KakouPlan =
  [ # plan.id 保守/切り替え時間,製造時間, 累積 
   [:kakou ,[58,59],"06/08-09:19",170.minute,[[1000  ,:wf]],"普3×10(東原)同じ銘柄切り替え。移動律速。製造が休み前に入る"],
   [:kakou ,[58,63],"06/08-09:04",170.minute,[[187661,:wf]],"普3×10(東原)12高級(東原)切り替え60分"],
   [:kakou ,[59,63],"06/20-13:11",170.minute,[[200000,:wf]],"普3×10(東原)12高級(東原)切り替え60分水曜日"],
   nil
  ].
  each{|plan| plan[2] = Time.parse("2012/"+plan[2] ) if plan}
ShozoPlan =
  [
   [:shozoe,[58,59],"06/08-08:09",170.minute,[[1000  ,:wf]],"普3×10(東原)同じ銘柄切り替え"],
   [:shozoe,[58,59],"06/09-08:04",170.minute,[[300000,:wf]],"普3×10(東原)WF替え"],
   [:shozoe,[59,63],"06/08-09:30",170.minute,[[18766,:wf]],"普3×10(東原)12高級(東原)切り替え8時間"],
   [:shozoe,[60,59],"06/08-08:00",170.minute,[[200000,:wf]],"普3×10(東原) 休転が6/8 まで入る"],
   [:shozoe,[60,59],"06/07-02:05",170.minute,[[00000,:wf]],"普3×10(東原) 休転前に製造が終わる"],
   [:shozoe,[60,63],"06/08-08:00",170.minute,[[1876,:wf]],"普3×10(東原)12高級(東原)切替8時間休転が6/8 まで入る"],
   nil
  ].
  each{|plan| plan[2] = Time.parse("2012/"+plan[2] ) if plan}

YojoPlan =
  [
   [:yojo  ,[58,59],"06/08-09:35",170.minute,[],"普3×10(東原)同じ銘柄切り替え"],
   [:yojo  ,[58,53],"06/08-08:09",170.minute,[],"普3×10(東原)16F化粧(西新)西の移動は60分"],
   #[[37,36],[240.minute,[49 ]],[ 5.minute,[]], [240.minute,240.minute,[49    ]], "普3×10(東原)水曜日"],
   #[[35,42],[  0.minute,[nil]],[40.minute,[]], [ 40.minute, 40.minute,["切替"]], "普3×10(東原)F3×10(西原)"],
   #[[40,34],[  0.minute,[nil]],[60.minute,[]], [ 60.minute, 60.minute,["切替"]], "12高級(東原)ショップ(東原)"],
   nil
  ].
  each{|plan| plan[2] = Time.parse("2012/"+plan[2] ) if plan}

Plan = KakouPlan+ShozoPlan#+YojoPlan
### 乾燥
DryPlan =
  [
   [:dryo,[64,65],"06/08-13:10", 5.minute,[],"普3×10(東原)同じ銘柄切り替え、製造が休み前に入る"],
   [:dryo,[64,69],"06/08-13:45",40.minute,[],"普3×10(東原)12高級(東原)切り替え40分"],
   [:dryo,[66,67],"06/04-08:00", 5.minute,[],"普3×10(東原) 休転が6/4 まで入る"],
   nil
   

  ].
  each{|plan| plan[2] = Time.parse("2012/"+plan[2] ) if plan}

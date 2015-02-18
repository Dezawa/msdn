#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'pp'

  def id_dump_of(ary_of_combination)
    "[" + ary_of_combination.map{ |comb| comb.map(&:id).join(",")}.join("],[")+"]"
  end
  
  def id_map_of(ary_of_combination)
    ary_of_combination.map{ |comb| comb.map(&:id)}
  end
   
  def id_map_of_ary_of_combination_of_combination(ary_of_combination)
    ary_of_combination.map{ |combs| combs.map{ |comb| comb.map(&:id)}}
  end
  
 

Limit_data="
ID,名前,  看護師長,主任,リーダー,看護師,準看護師,Aチーム,Bチーム,公休,日勤,準夜,深夜,年休,夜勤計,勤務計
1,泉川さだよ   ,  ,＿,＿,○,＿,＿,＿,8,20,2,2,1,0,0
2,室伏あい     ,＿,○,＿,○,＿,＿,＿,8,20,2,2,1,0,0
3,瀧本イソ     ,＿,○,＿,○,＿,○,＿,8,20,5,5,1,0,0
4,石川スミ     ,＿,＿,○,○,＿,○,＿,8,20,5,5,1,0,0
5,鈴木静江     ,＿,＿,○,○,＿,○,＿,8,20,5,5,1,9,22
6,奥津ハルヱ   ,＿,＿,○,○,＿,○,＿,8,20,5,5,1,9,22
7,亀井タケ     ,＿,＿,○,○,＿,○,＿,8,20,5,5,1,9,22
8,石井菊江     ,＿,＿,○,○,＿,○,＿,8,20,5,5,1,9,10
9,鈴木ミツ子   ,＿,＿,＿,○,＿,○,＿,8,20,5,5,1,9,10
10,安田愛子    ,＿,＿,○,○,＿,○,○,8,20,5,5,1,9,22
11,井上千枝子  ,＿,＿,○,○,＿,＿,○,8,20,5,5,1,9,22
12,鈴木美代子  ,＿,＿,○,○,＿,＿,○,8,20,5,5,1,9,22
13,碓井かつゑ  ,＿,＿,○,○,＿,＿,○,8,20,5,5,1,9,22
14,岩本カネ    ,＿,＿,＿,○,＿,＿,○,8,20,5,5,1,0,22
15,田代いね子  ,＿,＿,＿,○,＿,＿,○,8,20,5,5,1,9,22
16,高橋よね子  ,＿,＿,＿,○,＿,＿,○,8,20,5,5,1,9,22
17,高田ハル    ,＿,＿,＿,○,＿,＿,○,8,20,4,4,1,7,22
18,山田サダ    ,＿,＿,＿,○,＿,＿,○,8,20,5,5,1,9,22
19,田代すみ子  ,＿,＿,＿,○,＿,＿,○,8,20,5,5,1,9,22
20,小谷松江    ,＿,＿,＿,○,＿,＿,○,8,20,5,5,1,9,22
21,高木ヤエ    ,＿,＿,＿,○,＿,＿,○,8,20,5,5,1,9,22
22,加藤文      ,＿,＿,＿,○,＿,＿,○,8,20,5,5,1,9,22
23,佐々木キクヱ,＿,＿,＿,○,＿,＿,○,8,20,5,5,1,9,22
24,奥津成子    ,＿,＿,＿,○,＿,○,○,8,20,5,5,1,9,22
25,荒井マツ    ,＿,＿,＿,○,＿,○,○,8,20,5,5,1,9,22
26,鈴木キミ    ,＿,＿,＿,○,＿,○,○,8,20,5,5,1,9,22
27,阿部カネ子  ,＿,＿,＿,○,＿,○,○,8,20,5,5,1,9,22
28,飯嶋ハツ子  ,＿,＿,＿,○,＿,○,○,8,20,5,5,1,9,22
29,片岡鶴子    ,＿,＿,＿,○,＿,○,＿,8,20,5,5,1,9,22
30,劒持富江    ,＿,＿,＿,○,＿,○,＿,8,20,5,5,1,9,22
31,上保百合子  ,＿,＿,＿,○,＿,○,＿,8,20,5,5,1,0,0
32,田代つる子  ,＿,＿,＿,○,＿,○,＿,8,20,5,5,1,0,0
33,加藤福江    ,＿,＿,＿,○,＿,○,＿,8,20,5,5,1,0,0
"
def update
  Limit_data.split("\n").each{ |l|
    next unless /^\d+,/ =~ l
    clms = l.split(",")
    id = clms[0].to_i
    nurce = Hospital::Nurce.find(id)
    limits = Hash[*[:code1,:code2,:code3,:coden,:night_total,:kinmu_total].
                  zip( clms[10,5] ).flatten]
    nurce.limit.update_attributes(limits)

    need_role_ids  = [1,2,3,4,5,9,10]
    role_id=[]
   clms[2,7].each_with_index{ |role,idx|
      role_id << need_role_ids[idx] if role == "○"
    }
    roles = nurce.hospital_roles.select{ |role| role.bunrui == 3}
    roles += Hospital::Role.find(role_id)
    nurce.hospital_roles = roles
  }
end
 Expects = 
    { 1 => 
    { "3" => [
            [3,9,10],    #tight_role
            [5,6,7,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], #assinable_nurces
            [[20, 19, 21, 18, 22, 23, 15, 16, 17], #  4 10    gather_by_each_group_of_role
             [29, 9, 30],                          #  49
             [26, 24, 28, 27, 25],                 #  4910
             [12, 13, 11],                         # 34 10
             [7, 8, 5, 6],                         # 349
             [10]                                  # 34910
            ],    
            [20, 29, 26, 12, 7, 10, 19, 9, 24, 13, 8, 21, 30, 28], #   assinable_nurces_by_cost_size_limited
              [5,5,4,5,5,5,5,5,5], # remain          ],
              ["1023.4", "1023.7", "1330.0", "1023.3", "1023.1","1023.1", "1023.2", "1023.3", "1023.4"]  #cost
             ],
      "2" => [
            [3,9,10],    #tight_role
            [5,6,7,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], #assinable_nurces

            [[20, 19, 21, 18, 22, 23, 15, 16, 17],   #  4 10    #gather_by_each_group_of_role
             [29, 9, 30],                            #  49
             [26, 24, 28, 27, 25],                   #  4910
             [12, 13, 11],                           # 34 10
             [7, 8, 5, 6],                           # 349
             [10]                                   # 34910  8324.37115197942]
            ],    
            [20, 29, 26, 12, 7, 10, 19, 9, 24, 13, 8, 21, 30, 28] , #   assinable_nurces_by_cost_size_limited
              [5,5,4,5,5,5,5,5,5], # remain          ],
              ["1023.4","1023.7", "1330.0", "1023.3", "1023.1", "1023.1", "1023.2", "1023.3", "1023.4"] #cost

             ]

    },
    2 => 
    { "3" => [
            [3,9,10],    #tight_role
            [5,6,7,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], #assinable_nurces
            [ [15, 16, 23,   18, 22, 20, 21, 19, 17],   #  4 10    gather_by_each_group_of_role
              [ 9, 29, 30],                             #  49
              [24, 25, 26,   27, 28],                   #  4910
              [11, 12,      13],                        # 34 10
              [ 5,  6,       7,   8],                   # 349
              [10]                                      # 34910
            ],    
            [15, 9, 24, 11, 5, 10, 16, 29, 25, 12, 6, 23, 30, 26], #   assinable_nurces_by_cost_size_limited
              [3,3,4,5,5,5,5,5,3], # remain          ],
              [1730, 1730, 1330, 1023, 1023, 1023, 1023, 1023, 1730]  #cost
             ],
   "2" => [
            [3,9,10],    #tight_role
            [5,6,7,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], #assinable_nurces
            [[15, 20, 22, 18, 19, 21, 23, 16, 17],  #  4 10    gather_by_each_group_of_role 
             [29, 30, 9],                            #  49
             [26, 25, 27, 28, 24],                   #  4910
             [11, 13, 12],                           # 34 10
             [6, 7, 8, 5],                           # 349
             [10]                                    # 34910
            ],    
            [15, 9, 24, 11, 5, 10, 16, 29, 25, 12, 6, 23, 30, 26] , #   assinable_nurces_by_cost_size_limited
              [5,3,4,5,5,5,5,5,3], # remain          ],
              [1023, 1730, 1330, 1023, 1023, 1023, 1023, 1023, 1730]  #cost

          ]
    }
  }

Log3 = []
Log3[1] ="
HP ASSIGN 1日entry-1
  HP ASSIGN 1 ________________________________
  HP ASSIGN 2 ________________________________
  HP ASSIGN 3 ________________________________
  HP ASSIGN 4 ________________________________
  HP ASSIGN 5 ________________________________
  HP ASSIGN 6 ________________________________
  HP ASSIGN 7 ________________________________
  HP ASSIGN 8 ________________________________
  HP ASSIGN 9 ________________________________
  HP ASSIGN 10 ________________________________
  HP ASSIGN 11 ________________________________
  HP ASSIGN 12 ________________________________
  HP ASSIGN 13 ________________________________
  HP ASSIGN 14 ________________________________
  HP ASSIGN 15 ________________________________
  HP ASSIGN 16 ________________________________
  HP ASSIGN 17 ________________________________
  HP ASSIGN 18 ________________________________
  HP ASSIGN 19 ________________________________
  HP ASSIGN 20 ________________________________
  HP ASSIGN 21 ________________________________
  HP ASSIGN 22 ________________________________
  HP ASSIGN 23 ________________________________
  HP ASSIGN 24 ________________________________
  HP ASSIGN 25 ________________________________
  HP ASSIGN 26 ________________________________
  HP ASSIGN 27 ________________________________
  HP ASSIGN 28 ________________________________
  HP ASSIGN 29 ________________________________
  HP ASSIGN 30 ________________________________
  HP ASSIGN 31 ________________________________
  HP ASSIGN 32 ________________________________
  HP ASSIGN 33 ________________________________
HP A"

Log3[3] = "
HP ASSIGN 3日entry
assign_by_re_entrant
  HP ASSIGN 1 ________________________________
  HP ASSIGN 2 ________________________________
  HP ASSIGN 3 ________________________________
  HP ASSIGN 4 ________________________________
  HP ASSIGN 5 ________________________________
  HP ASSIGN 6 ________________________________
  HP ASSIGN 7 ________________________________
  HP ASSIGN 8 ________________________________
  HP ASSIGN 9 _330____________________________
  HP ASSIGN 10 ________________________________
  HP ASSIGN 11 _330____________________________
  HP ASSIGN 12 _220330_________________________
  HP ASSIGN 13 ________________________________
  HP ASSIGN 14 ________________________________
  HP ASSIGN 15 _330____________________________
  HP ASSIGN 16 _220330_________________________
  HP ASSIGN 17 ________________________________
  HP ASSIGN 18 ________________________________
  HP ASSIGN 19 ________________________________
  HP ASSIGN 20 ________________________________
  HP ASSIGN 21 ________________________________
  HP ASSIGN 22 ________________________________
  HP ASSIGN 23 _220____________________________
  HP ASSIGN 24 ________________________________
  HP ASSIGN 25 ________________________________
  HP ASSIGN 26 ________________________________
  HP ASSIGN 27 ________________________________
  HP ASSIGN 28 ________________________________
  HP ASSIGN 29 ________________________________
  HP ASSIGN 30 _220330_________________________
  HP ASSIGN 31 ________________________________
  HP ASSIGN 32 ________________________________
  HP ASSIGN 33 ________________________________
HP AS"

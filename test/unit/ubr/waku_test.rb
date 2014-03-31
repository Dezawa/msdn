# -*- coding: utf-8 -*-
require 'test_helper'

Waku        = "1A2C"
class Ubr::WakuTest < ActiveSupport::TestCase
  fixtures :ubr_wakus
  # Replace this with your real tests.
  def setup
    @Waku    = Ubr::Waku.waku true #load_from_master
    @waku    = @Waku[Waku]
    @Lotlist = Ubr::LotList.
      lotlist(true,:file => File.join(RAILS_ROOT,"test/testdata/SCMstocklist.csv"))
#puts "@Lotlist.size=#{@Lotlist.size}"
  end

  must "0A02の方向は" do
    assert_equal "↓",@Waku["0A02"].direct_to
    assert_equal Pos[0,1],@Waku["0A02"].direction
  end
  must "0A02の型" do
    pp [@Waku["0A02"].direction,@Waku["0A02"].palette ]
    assert_equal :D14 , @Waku["0A02"].kata
  end

  must "0A02は通路か" do
    assert !@Waku["0A02"].tuuro? 
  end

  must "0A02のto_s" do
    assert_equal "0A02" ,@Waku["0A02"].to_s
  end

  must "通路枠は" do
    assert_equal 54,Ubr::Waku.tuuro.size
    assert_equal [
                  "0AZZ", "0CZZ", "0DZZ", "0EZZ", "0FZZ",
                  "1A2Z", "1A3Z", "1B2Z", "1B3Z", "1B4Z", "1B5Z", "1ZZZ",
                  "2C2Z", "2D1Z", "2D2Z", "2E3Z", "3F1Z", "3F2Z",
                  "4G1Z", "4H1Z", "4H2Z", "5I1Z", "5J1Z", "5K1Z", "5L1Z","6O1Z", "6O2Z", 
                  "7AZZ", "7BZZ", "7CZZ", "7DZZ", "7IZZ", "7JZZ", "7KZZ", "7NZZ", 
                  "7PZZ", "7SZZ", "7TZZ", "7UZZ", "7ZZZ",
                  "9G2Z", "9G3Z", "9G4Z", "9G5Z", "9JZZ", 
                  "9L1Z", "9L2Z", "9L3Z", "9L4Z", "9L5Z", "9L6Z", "9L7Z",
                  "9L8Z", "9LZZ"
                 ],Ubr::Waku.tuuro.map(&:name).sort
    assert_equal ["2C2Z", "2D1Z", "2D2Z"],Ubr::Waku.tuuro(1).map(&:name).sort
    assert_equal ["2C2Z", "2D1Z", "2D2Z", "2E3Z"],Ubr::Waku.tuuro(/^2/).map(&:name).sort
    assert_equal ["2C2Z", "2D1Z", "2D2Z"],Ubr::Waku.tuuro("2号倉庫").map(&:name).sort
  end
  
  wakus = %w(1A2C 1B5M 2C3C )
  #        [WithPull,WithoutPull,OnlyExport,無指定]
  lotsize = [[2,1,1,2],[9,8,1,9],[2,0,1,2]]
  paletsize=[[30,27,3,30],[68,65,3,68],[39,0,12,39]]
  weights  =[[28875,26400,2475,28875],[64925,61925,3000,64925],[38650,0,12000,38650]]
  occupied =[[10,9,1,10],[34,32,1,34],[13,0,4,13]] 
  #  [空き,引き合い,引き合い無,過剰]
  used_map = [[0,1,9,0],[0,0,0,5],[0,10,0,0]]
  #                       ↑パレット ZZZZは1段積み扱い。14パレット-5=9余分
  must "#{Waku}のロット" do
    #pp @Lotlist
    assert_equal ["B3381", "B3388"],@waku.lot_list( WithPull).map(&:lot_no)
    assert_equal ["B3388"],@waku.lot_list( WithoutPull).map(&:lot_no)
    assert_equal ["B3381", "B3388"],@waku.lot_list.map(&:lot_no)
  end

  wakus.zip(lotsize).each{ |waku,size|
    must  "#{waku}のlot_list" do 
      @waku1    = @Waku[waku]           
      assert_equal size[0],@waku1.lot_list( WithPull).size    , "#{waku}のlot_list WithPull"    
      assert_equal size[1],@waku1.lot_list( WithoutPull).size , "#{waku}のlot_list WithoutPull" 
      assert_equal size[2],@waku1.lot_list( OnlyExport).size  , "#{waku}のlot_list OnlyExport"  
      assert_equal size[3],@waku1.lot_list.size               , "#{waku}のlot_list all"         
    end
  }

  wakus.zip(weights).each{ |waku,size|
    must  "#{waku}の重量" do 
      @waku1    = @Waku[waku]     
      assert_equal size[0],@waku1.weight( WithPull)     , "#{waku}の重量 WithPull"    
      assert_equal size[1],@waku1.weight( WithoutPull)  , "#{waku}の重量 WithoutPull" 
      assert_equal size[2],@waku1.weight( OnlyExport)    , "#{waku}の重量 OnlyExport"  
      assert_equal size[3],@waku1.weight                , "#{waku}の重量 all"         
    end
  }
  wakus.zip(paletsize).each{ |waku,size|
    must  "#{waku}のパレット数" do 
      @waku1    = @Waku[waku]           
      assert_equal size[0],@waku1.paret_su( WithPull)       , "#{waku}のパレット数 WithPull"    
      assert_equal size[1],@waku1.paret_su( WithoutPull)    , "#{waku}のパレット数 WithoutPull" 
      assert_equal size[2],@waku1.paret_su( OnlyExport)      , "#{waku}のパレット数 OnlyExport"  
      assert_equal size[3],@waku1.paret_su                  , "#{waku}のパレット数 all"         
    end
  }

  wakus.zip(occupied).each{ |waku,size|
    must  "#{waku}の占有数" do 
      @waku1    = @Waku[waku]           
      assert_equal size[0],@waku1.occupied( WithPull)       , "#{waku}の占有数 WithPull"    
      assert_equal size[1],@waku1.occupied( WithoutPull)    , "#{waku}の占有数 WithoutPull" 
      assert_equal size[2],@waku1.occupied( OnlyExport)     , "#{waku}の占有数 OnlyExport"  
      assert_equal size[3],@waku1.occupied                  , "#{waku}の占有数 all"         
    end
  }

  wakus.zip(used_map).each{ |waku,size|
    must  "#{waku}の占有数" do 
      @waku1    = @Waku[waku]           
      assert_equal [size],@waku1.used_map       , "#{waku}のused_map"    
    end
  }

  must "空？" do
    assert !@waku.empty?( WithoutPull)
    assert !@waku.empty?( WithPull)
    assert @Waku["1A2E"].empty?( WithoutPull)
    assert !@Waku["1A2E"].empty?( WithPull)
    assert !@Waku["1A2E"].empty?
  end
    
  must "1A3Cの占有" do # G3516D は Y14、55袋積み、2段。1100俵 20パレット
    waku = @Waku["1A3C"]
    lot_main_part,lot_paper_le_1ton = waku.lot_sort_by_packed#( WithoutPull)
    assert_equal [["G3276D", "G3516D"],[]], [lot_main_part.map(&:lot_no),lot_paper_le_1ton.map(&:lot_no) ]
    # G3516D は Y14、55袋積み、2段。1100俵 20パレット
    assert_equal [[1, 20], [] ], [lot_main_part.map(&:paret_su),lot_paper_le_1ton.map(&:paret_su) ]
    # G3276D は１枡使う                                 3 2 1 段の空き枡数
    assert_equal 1,waku.stack_palet(lot_main_part[0],[0,0,0,10]),"G3276D は１枡使う"
    assert_equal 20,lot_main_part[1].paret_su,"G3516D は 20パレット"
    assert_equal  2,lot_main_part[1].lot.stack_limit,"G3516D は 2段まで"
    assert_equal 10,waku. stack_2dan(20,[0,0,0,9]),"G3516D は2dan 10枡使う"
    assert_equal 10,waku.stack_palet(lot_main_part[1],[0,0,0,9]),"G3516D は 10枡使う"
    assert_equal 10,waku.stack_2dan(lot_main_part[1].paret_su,[0,0,0,9])
   assert_equal 11,waku.occupied( WithPull)
   assert_equal 11,waku.occupied( WithoutPull)
  end

  # masu_occupyed   [空き,引き合い,引き合い無,過剰]
  [["2C3H",[[0,2,8,0]]],
   ["1B2Z",[[0, 4, 1, 0], [0, 5, 1, 0]]],
   ["1A3C",[[0, 0,10,0]]], # 過剰が１の時は、積み方計算の誤差もあるので0にする
   ["1B5M",[[0,0,0,5]]]
    ].each{ |waku_name,ary|
      must "枠#{waku_name}のused_map" do
        waku=@Waku[waku_name]
        assert_equal ary, waku.used_map
      end
    }

  must "4H1Mおかしいので個別に見る" do
    waku = Ubr::Waku.by_name "4H1M"
    lot_main_part , lot_paper_le_1ton = waku.lot_sort_by_packed(WithPull)
    assert_equal [2,0],[lot_main_part.size , lot_paper_le_1ton.size],"4H1M lot_sort_by_packed"
    assert_equal [2,1],lot_main_part.map{ |seg| waku.stack_palet(seg,[0,0,0,6])},"4H1M stack_paletは"
    assert_equal 3,lot_main_part.inject(0){ |need,seg| f= waku.stack_palet(seg,[0,0,0,6]);need + f}
    assert_equal 0,waku.stack_paper_palet(lot_paper_le_1ton,[0,0,0,6]),"4H1M stack_paper_palet"
    assert_equal 4,waku.occupied(WithPull),"4H1M 占有は3"
  end

  must "2C3Fおかしいので個別に見る" do
    waku = Ubr::Waku.by_name "2C3F"
    lot_main_part , lot_paper_le_1ton = waku.lot_sort_by_packed(WithPull)
    assert_equal [2,7,5],lot_main_part.map{ |seg| waku.stack_palet(seg,[0,0,0,10])},"stack_paletは"
    assert_equal  0,waku.stack_paper_palet(lot_paper_le_1ton,[0,0,0,10]),"2C3F stack_paper_palet"
    assert_equal 14,waku.occupied(WithPull),"占有は3"
  end

  #         size [Fと40袋を越える紙,40袋までの紙] のロット数
  [       # palet [ [正規量のパレット数],[量不足パレット数] ]
   ["1A3D",[1,1],[[19],[1]]       ,10,[[0,0,10,0]]],  # 40袋越えるの紙。11枠となるが、誤差考え溢れ0となる
   ["2C3F",[3,0],[[6,19,13],[]],10,[[0,1,9,0]]],  # 引き合いが 13パレットあり
   # without = 8, within= 12, vacant = 0, => [0,2,8,0]
   ["2D1G",[1,0],[[24],[]]     , 9,[[1,8,0,0]]],  # 40袋越えの紙 125(3..5),842(21..2)
   ["4H1D",[3,2],[[2,2,2],[1,1]], 6,[[2,0,4,0]]],  # 40袋越えの紙,40袋までの紙
   ["4H1M",[2,0],[[5,2],[]]      , 6,[[2,0,4,0]]],  # F 5ton,N 2ton。一つは N2 45袋900kg。引き無し
    nil].                                           # 
    each{ |waku_name,size,palet,masu,masu_occupyed|
    # masu_occupyed   [空き,引き合い,引き合い無,過剰]
    next unless waku_name
    must "枠 #{waku_name} のlot_sort_by_packed" do
      waku = Ubr::Waku.by_name(waku_name)
      main , paper = waku.lot_sort_by_packed
      assert_equal size , [main.size,paper.size],"枠 #{waku_name} のロット数"
      assert_equal palet ,[ main.map{ |seg| seg.paret_su},
                            paper.map{|seg| seg.paret_su}
                          ],"枠 #{waku_name} のパレット数"
      assert_equal masu ,waku.kawa_suu,"枠 #{waku_name} の桝数"
      assert_equal masu_occupyed ,waku.used_map,"枠 #{waku_name} の枠利用状況"
      end
  }

  [ [0,7],[1,3],[2,2],[3,3],[4,3],[5,2],[6,1],[7,1], [8,5]].
    each{ |idx,num_of_tuuro|
    msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first} の通路枠数" 
    must msg do
      assert_equal num_of_tuuro,Ubr::Waku.tuuro(idx).size,msg
    end
  }

end
__END__
    def creat_segments(count_list)
      count_list.map{ |count| Ubr::Lot.new(:lot => "dmy", :waku => "2D1C",:count => count ) }
      
    end

  # id,枠,通路,fill-引合-通路
  #  1                  2                3                4             5            
  AAA = 
    [ [0,126,7,110,4,3],[1,66,3,61,4,2],[2,44,2,35,2,0],[3,91,3,77,1,1],[4,92,4,47,0,1],
    # 6            2-2F              5-2F             総合倉庫
    [5,38,2,33,1,0],[6, 111,1,84,2,0],[7,107,2,80,1,0], [8,156 ,0,136,2,0]]


  AAA.each{ |idx,waku_su,tuuro,fill,pull,z|
    num_of_empty = (waku_su - tuuro)-(fill-pull-z)
    msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first}" +"の穴数"
    must msg do
      assert_equal num_of_empty,Ubr::Waku.aria(idx).select{ |w| w.empty? && /Z$/ !~ w.name}.size,msg
    end
  }

  AAA.each{ |idx,waku_su,tuuro,fill,pull,z|
    num_of_empty = (waku_su - tuuro)-(fill-pull-z)
    msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first}" +" by self.empty"
    must msg do
      assert_equal num_of_empty,Ubr::Waku.empty(idx,true).size,msg
    end
  }


  AAA.each{ |idx,waku_su,tuuro,fill,pull,z|
    msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first}" +"の枠数"
    must msg do
      assert_equal waku_su     ,Ubr::Waku.aria(idx).size ,msg
    end
  }
  AAA.each{ |idx,waku_su,tuuro,fill,pull,z|
    msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first}" +"の通路枠数"
    must msg do
       assert_equal tuuro  ,Ubr::Waku.aria(idx).select{ |waku| /Z$/ =~ waku.name}.size ,msg
    end
  }

  AAA.each{ |idx,waku_su,tuuro,fill,pull,z|
    msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first}" +"のエリア利用数"
    must msg do
     assert_equal fill        ,Ubr::Waku.aria(idx).select{ |waku| waku.lot_list.size>0}.size ,msg
    end
  }

  AAA.each{ |idx,waku_su,tuuro,fill,pull,z|
    msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first}" +"の通路置き数"
    must msg do
      assert_equal z ,Ubr::Waku.tuuro(idx).select{ |waku| waku.lot_list(true).size>0}.size,msg
    end
  }

  AAA.each{ |idx,waku_su,tuuro,fill,pull,z|
    msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first}" +"の引き当て数"
    must msg do
      assert_equal pull ,
      Ubr::Waku.aria(idx).select{ |waku| waku.lot_list.size>0}.size - 
        Ubr::Waku.aria(idx).select{ |waku| waku.lot_list(true).size>0}.size ,msg
    end
  }

  aria = "6号倉庫"
  must aria + " の枠の充填具合" do
    by_occupied = Ubr::Waku.by_occupied(aria,true)
    max_occupy = by_occupied.keys.sort[-1]
    #pp (0..10).map{ |o| by_occupied[o].map(&:name).sort rescue nil}
    assert_equal [6, 6, 12, 4, 3, nil, 3, 3, nil, nil, 1],
  (0..max_occupy).map{ |occu| by_occupied[occu] ? by_occupied[occu].size : nil }
  end

  aria = "6号倉庫"
  must aria + " の量・充填" do
    by_volume_occupied = Ubr::Waku.by_volume_occupied(aria,true)
    key_volume = by_volume_occupied.keys.sort
#puts "#############"
#    pp key_volume 
#    pp key_volume.map{ |k_v| by_volume_occupied[k_v].keys.sort}
#    pp key_volume.map{ |k_v| 
#      (1..10).map{ |masu| by_volume_occupied[k_v][masu].map(&:name).sort rescue nil}}

    puts "#############"
    #                     容量別       桝 枠
    pp by_volume_occupied[[6, 2, 0, 0]][0].class
    pp by_volume_occupied[[6, 2, 0, 0]][0].size
    pp by_volume_occupied[[6, 2, 0, 0]][0][0].class
    pp by_volume_occupied[[6, 2, 0, 0]][0][0].name
    pp by_volume_occupied[[6, 2, 0, 0]][1].class
    pp by_volume_occupied[[6, 2, 0, 0]][1].size
    pp by_volume_occupied[[6, 2, 0, 0]][1][0].class
    pp by_volume_occupied[[6, 2, 0, 0]][1][0].name
    pp by_volume_occupied[[6, 2, 0, 0]][1][0].lot_list.class
    pp by_volume_occupied[[6, 2, 0, 0]][1][0].lot_list.size
    pp by_volume_occupied[[6, 2, 0, 0]][1][0].lot_list[0].class
    pp by_volume_occupied[[6, 2, 0, 0]][1][0].lot_list[0].lot_no
    pp by_volume_occupied[[6, 2, 0, 0]][1][0].lot_list.map(&:lot_no)
  end

end
__END__

#####################
## 古い積み方
  [ [[4,5,3],[0,0,0,4],[0,0,0,1],0,[0,0,0,4],[0,0,0,0],"桝半端で足りる"], # 2+2+2  24-18=6
    [[4,8,6],[0,0,0,4],[0,0,0,1],0,[0,0,0,4],[0,0,0,0],"桝半端で溢れるが足らす"], # 2+3+3  24-18=6
    [[4,15,6],[0,0,0,4],[0,0,0,1],1,[0,0,0,3],[0,0,0,21],"桝半端無くなり1つ消費"], # 2+4+3  24-18=6
    [[14,15,6],[0,0,0,4],[0,0,0,1],1,[0,0,0,3],[0,0,0,21],"桝半端越え1つ消費"], # 4+4+3  24-18=6
    [[14,15,6],[0,0,0,4],[0,0,0,0],1,[0,0,0,3],[0,0,0,13],"桝半端なし"], # 4+4+3  24-18=6
    [[40+4,80+5,40+3],[0,0,0,4],[0,0,0,1],2,[0,0,0,2],[0,0,0,18],"1桝消費、桝半端無くなる"], # 2+2+2  24-18=6
    [[40+4,80+5,40+3],[0,0,0,4],[0,0,0,0],2,[0,0,0,2],[0,0,0,9],"2桝消費、桝半端2できる"], # 2+2+2  24-18=6
    [[40+4,80+5,40+3],[0,0,4,1],[0,0,0,0],2,[0,0,3,0],[0,0,3,0],"2桝消費2段に食い込む、桝半端2できる"], # 2+2+2  24-18=6
    [[40+4,80+5,40+3],[0,0,4,1],[0,0,0,1],2,[0,0,3,0],[0,0,12,0],"3桝半端1。消費2段に食い込む、桝半端2できる"], # 2+2+2  24-18=6
   nil
  ].each{ |count_list,remain,last_masu,ret,remain2,last_masu_men2,msg|
    next unless count_list
    must "紙の置き方" + msg do

      segment_list = creat_segments(count_list)
      #pp ["count map",segment_list.map{ |seg| seg.count}]
      rslt = @waku.masu_used_paper(segment_list,remain,last_masu)

      assert_equal ret,rslt,"桝消費 "+msg
      assert_equal remain2,remain,"桝残り "+msg
      assert_equal last_masu_men2,last_masu,"桝半端残り面数 "+msg
    end
  }
  ### masu_used_paper_hasu の評価
  [[5,[0,0,0,3],[0,0,0,15],0,[0,0,0,3],[0,0,0,10],"3段端数余裕あり"],
   [5,[0,0,0,3],[0,0,0, 1],0,[0,0,0,3],[0,0,0, 0],"3段端数足りない"],
   [5,[0,0,0,3],[0,0,0, 0],1,[0,0,0,2],[0,0,0,19],"3段端数ない"],
   [5,[0,0,2,0],[0,0,10,0],0,[0,0,2,0],[0,0,5, 0],"2段端数余裕あり"],
   [5,[0,0,2,0],[0,0,4, 0],0,[0,0,2,0],[0,0,0, 0],"2段端数足りない"],
   [5,[0,0,2,0],[0,0,0, 0],1,[0,0,1,0],[0,0,13,0],"2段端数ない"],
    nil
  ].each{ | men,remain0,last_masu_men0,ret,remain2,last_masu_men2,msg|
    next unless men
    remain,last_masu_men = [remain0.dup,last_masu_men0.dup ]
    must msg+" の評価" do
      rslt = @waku.masu_used_paper_hasu(men,remain,last_masu_men)
      assert_equal ret,rslt,msg+" 使用数"
      assert_equal remain2,remain,msg+" 枠残り"
    end
  }
  ### masu_used_3stack の評価
  # parets,remain,last_masu
  Dan3 = 
    [ [9, [0,0,0,6],[0,0,0,0],3,[0,0,0,3],[0,0,0,0],  " ピッタリ3段"],
      [9, [0,0,0,6],[0,0,0,1],3,[0,0,0,3],[0,0,0,1],  " 1段余りが残ってた"],
      [8, [0,0,0,6],[0,0,0,1],3,[0,0,0,3],[0,0,0,2],  " 1段余りが残ってた"],
      [9, [0,0,4,2],[0,0,0,0],4,[0,0,2,0],[0,0,1,0],  " 3段が不足"],
      [9, [0,0,4,2],[0,0,0,1],3,[0,0,3,0],[0,0,0,0],  " 3段が不足。1段余りが残ってた"],
      [9, [0,0,4,2],[0,0,0,2],3,[0,0,3,0],[0,0,1,0],  " 3段が不足。1段余りが２残ってた"],
      [9, [0,0,6,0],[0,0,0,0],5,[0,0,1,0],[0,0,1,0],  " 3段なし"],
      nil
    ]
    Dan3.each{ |parets,remain0,last_masu0,masu,remain2,last_masu2,m|
    next unless parets
    msg = "3段銘柄：#{parets}パレット、#{remain0.join(',')} #{last_masu0.join(',')}"
    must msg do
      remain,last_masu = remain0.dup,last_masu0.dup
      ret = @waku.masu_used_3stack(parets,remain,last_masu)
      assert_equal masu,ret, msg+"  桝数"+m
      assert_equal remain2 , remain , " 桝残り"+m
      assert_equal last_masu2,last_masu, " 半端桝のあと何段"+m
    end
  }

  ### masu_used_2stack の評価
  # parets,remain,last_masu
  Dan2 = [ [9, [0,0,0,6],[0,0,0,0],5,[0,0,0,1],[0,0,0,1],  " ピッタリ3段"],
           [9, [0,0,0,6],[0,0,0,1],4,[0,0,0,2],[0,0,0,0],  " 1段余りが残ってた"],
           [8, [0,0,0,6],[0,0,0,1],4,[0,0,0,2],[0,0,0,1],  " 1段余りが残ってた"],
           [9, [0,0,4,2],[0,0,0,0],5,[0,0,1,0],[0,0,1,0],  " 3段が不足"],
           [9, [0,0,4,2],[0,0,0,1],4,[0,0,2,0],[0,0,0,0],  " 3段が不足。1段余りが残ってた"],
           [9, [0,0,4,2],[0,0,0,2],4,[0,0,2,0],[0,0,0,0],  " 3段が不足。1段余りが２残ってた"],
           [9, [0,0,6,0],[0,0,0,0],5,[0,0,1,0],[0,0,1,0],  " 3段なし"],
           nil
         ]
  Dan2.each{ |parets,remain0,last_masu0,masu,remain2,last_masu2,m|
    next unless parets
    msg = "2段銘柄：#{parets}パレット、#{remain0.join(',')} #{last_masu0.join(',')}"
    must msg do
      remain,last_masu = remain0.dup,last_masu0.dup
      ret = @waku.masu_used_2stack(parets,remain,last_masu)
      assert_equal masu,ret, msg+"  桝数"+m
      assert_equal remain2 , remain , " 桝残り"+m
      assert_equal last_masu2,last_masu, " 半端桝のあと何段"+m
    end
  }

  Dan3.each{ |parets,remain0,last_masu0,masu,remain2,last_masu2,m|
    next unless parets
    msg = "3段銘柄masu_used：#{parets}パレット、#{remain0.join(',')} #{last_masu0.join(',')}"
    must msg do
      remain,last_masu = remain0.dup,last_masu0.dup
      ret = @waku.masu_used(3,parets,remain,last_masu)
      assert_equal masu,ret, msg+"  桝数"+m
      assert_equal remain2 , remain , " 桝残り"+m
      assert_equal last_masu2,last_masu, " 半端桝のあと何段"+m
    end

}

  Dan2.each{ |parets,remain0,last_masu0,masu,remain2,last_masu2|
    next unless parets
    msg = "2段銘柄masu_used：#{parets}パレット、#{remain0.join(',')} #{last_masu0.join(',')}"
    must msg do
      remain,last_masu = remain0.dup,last_masu0.dup
      ret = @waku.masu_used(2,parets,remain,last_masu)
      assert_equal masu,ret, msg+"  桝数"
      assert_equal remain2 , remain , " 桝残り"
      assert_equal last_masu2,last_masu, " 半端桝のあと何段"
    end

}


# -*- coding: utf-8 -*-
require 'test_helper'
WithoutPull = true
WithPull    = false
Waku        = "1A2C"
class Ubr::WakuTest < ActiveSupport::TestCase
  fixtures :ubr_wakus
  # Replace this with your real tests.
  def setup
    @Waku    = Ubr::Waku.waku #load_from_master
    @waku    = @Waku[Waku]
    @lotlist = Ubr::LotList.
      lotlist(false,:file => File.join(RAILS_ROOT,"test/testdata/SCM在庫一覧.csv"))
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
    assert_equal 53,Ubr::Waku.tuuro.size
    assert_equal [
                  "0AZZ", "0CZZ", "0DZZ", "0EZZ", "0FZZ",
                  "1A2Z", "1A3Z", "1B2Z", "1B3Z", "1B4Z", "1B5Z", "1ZZZ",
                  "2C2Z", "2D1Z", "2D2Z", "2E3Z", "3F1Z", "3F2Z",
                  "4G1Z", "4H1Z", "4H2Z", "5I1Z", "5J1Z", "5L1Z","6O1Z", "6O2Z", 
                  "7AZZ", "7BZZ", "7CZZ", "7DZZ", "7IZZ", "7JZZ", "7KZZ", "7NZZ", "7PZZ", "7SZZ", "7TZZ", "7UZZ",
                  "7ZZZ",
                  "9G2Z", "9G3Z", "9G4Z", "9G5Z", "9JZZ", "9L1Z", "9L2Z", "9L3Z", "9L4Z", "9L5Z", "9L6Z", "9L7Z",
                  "9L8Z", "9LZZ"
                 ],Ubr::Waku.tuuro.map(&:name).sort
    assert_equal ["2C2Z", "2D1Z", "2D2Z"],Ubr::Waku.tuuro(1).map(&:name).sort
    assert_equal ["2C2Z", "2D1Z", "2D2Z", "2E3Z"],Ubr::Waku.tuuro(/^2/).map(&:name).sort
    assert_equal ["2C2Z", "2D1Z", "2D2Z"],Ubr::Waku.tuuro("2号倉庫").map(&:name).sort
  end

  must "#{Waku}のロット" do
    #pp @lotlist
    assert_equal ["B3381", "B3388"],@waku.lot_list( WithPull).map(&:lot_no)
    assert_equal ["B3388"],@waku.lot_list( WithoutPull).map(&:lot_no)
    assert_equal ["B3381", "B3388"],@waku.lot_list.map(&:lot_no)
  end

  must  "#{Waku}の重量" do 
    assert_equal 28875,@waku.weight( WithPull)
    assert_equal 26400,@waku.weight( WithoutPull)
    assert_equal 28875,@waku.weight
  end
  must  "#{Waku}のパレット数" do 
    assert_equal 30,@waku.paret_su( WithPull)
    assert_equal 27,@waku.paret_su( WithoutPull)
    assert_equal 30,@waku.paret_su
  end
  must  "1B5Mのパレット数" do 
    assert_equal 68,@Waku["1B5M"].paret_su( WithPull)
    assert_equal 65,@Waku["1B5M"].paret_su( WithoutPull)
    assert_equal 68,@Waku["1B5M"].paret_su
  end
  must "空？" do
    assert !@waku.empty?( WithoutPull)
    assert !@waku.empty?( WithPull)
    assert @Waku["1A2E"].empty?( WithoutPull)
    assert !@Waku["1A2E"].empty?( WithPull)
    assert !@Waku["1A2E"].empty?
  end
    
  must "1A3Cの占有" do # G3516D は Y14、55袋積み、2段

    waku = @Waku["1A3C"]
    lot_main_part,lot_paper_le_1ton = waku.lot_sort_by_packed#( WithoutPull)
   assert_equal [["G3276D", "G3516D"],[]], [lot_main_part.map(&:lot_no),lot_paper_le_1ton.map(&:lot_no) ]
   assert_equal [[1, 20], [] ], [lot_main_part.map(&:paret_su),lot_paper_le_1ton.map(&:paret_su) ]
    assert_equal 1,waku.stack_palet(lot_main_part[0],[0,10,0,0])
    assert_equal 4,waku.stack_palet(lot_main_part[1],[0,9,0,0])
    assert_equal 4,waku.stack_2dan(lot_main_part[1].paret_su,[0,9,0,0])
   assert_equal 1,waku.occupied( WithPull)
  end

  # masu_occupyed   [空き,引き合い,引き合い無,過剰]
  [["2C3H",[[0,2,8,0]]],
   ["1B2Z",[[0, 4, 1, 0], [0, 5, 1, 0]]],
   ["1A3C",[[0, 0, 9,1]]],
   ["1B5M",[[0,0,0,5]]]
    ].each{ |waku_name,ary|
      must "枠#{waku_name}のused_map" do
        waku=@Waku[waku_name]
        assert_equal ary, waku.used_map
      end
    }
end
__END__
    def creat_segments(count_list)
      count_list.map{ |count| Ubr::Lot.new(:lot => "dmy", :waku => "2D1C",:count => count ) }
      
    end

  #         lot数 [Fと40袋を越える紙,40袋までの紙]
  [
   ["1A3D",[1,0],[54]       ,10,[0,0,3,7]],  # 40袋越えるの紙
   ["2C3F",[4,0],[2,1,12,16],10,[0,2,8,0]],  # フレコン 1 1 4 6 = 12
   # without = 8, within= 12, vacant = 0, => [0,2,8,0]
   ["2D1G",[2,0],[22,4]     , 9,[0,0,9,0]],  # 40袋越えの紙 125(3..5),842(21..2)
   ["4H1D",[1,4],[3,1,1,1,1], 6,[2,0,4,0]],  # 40袋越えの紙,40袋までの紙
   ["4H1M",[2,0],[2,3]      , 6,[3,0,3,0]],  # 一つは N2 45袋900kg
    nil].
    each{ |waku_name,size,palet,masu,masu_occupyed|
    # masu_occupyed   [空き,引き合い,引き合い無,過剰]
    next unless waku_name
    must "枠 #{waku_name} のlot_sort_by_packed" do
      waku = Ubr::Waku.by_name(waku_name)
      main , paper = waku.lot_sort_by_packed
      assert_equal size , [main.size,paper.size],"枠 #{waku_name} のロット数"
      assert_equal palet ,[ main.map{ |seg| seg.paret_su},
                            paper.map{|seg| seg.paret_su}
                          ].flatten,"枠 #{waku_name} のパレット数"
      assert_equal masu ,waku.kawa_suu,"枠 #{waku_name} の桝数"
      assert_equal masu_occupyed ,waku.used_map,"枠 #{waku_name} の枠利用状況"
      end
  }

  # 枠   lot数 個数 桝
  [["2C3F", 3,        19,  8],  # 1tonフレコン、16+2+1 => 6+1+1 = 8
   ["2D1G", 2,      4+22, 2+8],  # 25kg紙 125+842 完全 3+21, 半端 5 + 2
   ["4H1D", 5, 3+1+1+1+1,   4],  # 2120/20k,250/25k 550/25 850/25 225/25 
   #                           -> 106=80+26 10=0+10, 22=0+22, 34=0+34, 9=0+9  
   ["1A3D", 1,        54, 54/3],#G3097D: 1 : 53.70ton
   nil
  ].each{ |waku_name,lot_num,paret_num,masu_num|
    next unless waku_name
    msg = waku_name+"のlot数 個数 使用桝"
    must msg do
      waku = Ubr::Waku.by_name(waku_name)
      assert_equal lot_num, waku.lot_list(true).size, waku_name+"のロット数"
      assert_equal paret_num, waku.paret_su(true), waku_name+"のパレット数"
      assert_equal masu_num, waku.occupied(true), waku_name+"の使用桝数"
    end
  }

  must "枠に加える" do
    waku = Ubr::Waku.waku["6O1U"]
#    pp waku.lot_list.size
    #pp @lotlist.list
    lot  = @lotlist.list[["G12324201M------N3", "K2086", "1", "-"]]
    segments = lot.segments
    segment0 = segments[0]

    waku.add(segment0)
   # pp waku.lot_list.size
  end


   # 1         2      3     4      5        6     2-2F   5-2F
  #[ [0,127],[1,65],[2,44],[3,91],[4,112-38],[5,38],[6, 96],[7,59+38],
  #  #  -0G 0J 0Z -7E
  #  [8,305+42+30+163],[9,20]].each{ |idx,num_of_all|
  #  msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first} の枠数" 
  #  must msg do
  #    assert_equal num_of_all,Ubr::Waku.aria(idx).size,msg
  #  end
  #}

  [ [0,7],[1,3],[2,2],[3,3],[4,4],[5,2],[6,1],[7,2], [8,0]].
    each{ |idx,num_of_tuuro|
    msg = "IDX #{idx} #{Ubr::Waku::Aria[idx].first} の通路枠数" 
    must msg do
      assert_equal num_of_tuuro,Ubr::Waku.tuuro(idx).size,msg
    end
  }
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


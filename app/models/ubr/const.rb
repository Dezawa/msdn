# -*- coding: utf-8 -*-
WithoutPull = true
WithPull    = false
StatFont = [[Postscript::Gothic,1.4],[Postscript::Bold,1.8],[Postscript::Gothic,1.4]]


module Ubr::Const

  SCM_stock_stat_FILEBASE = File.join(RAILS_ROOT,"tmp","ubr","SCM_stock_stat")

  Suuro2Retu = %w(2C2Z 2D1Z 1B4Z 1B2Z 1A2Z)
  @dir= File.dirname(__FILE__)
  if /www/ =~ @dir
    $LOAD_PATH << @dir
    MasterDir =  @dir
  else
    $LOAD_PATH << File.join(File.dirname(__FILE__),"../System") << "~/lib/ruby"
    MasterDir =  File.join(@dir,"../System/Master")
  end

  Oneways = %w(G123DC700V------F7 G123DC6061------F7 
               G123DC820------F7 G123DC830------F7 
               G123DC720------F7 G123DZ691------F7)

Converator = [[80.7,30.5],[80.7,32.5],[83.7,32.5],[83.7,30.5],[80.7,30.5]]

###############
# 0J倉庫
  x0 =  0.0  # x0  x1 x2                             x3    
  x1 = 4     #  +-------------------------------------+ y0 
  x2 = x1+4  #  |                                     |    
  x3 = 38    #  |                                     | y1 
  y0 =  0.0  #  |                                          
  y1 = 7.5   #  |                                     | y2 
  y2 = y1+4  #  |                                     |    
  y3 = 19    #  +---    ------------------------------+ y3 
             #                                             
  AC0J = Ubr::Floor.new(:name => "0J", :id => 12,
        :walls   => [ [[x1,y3],[x0,y3],[x0,y0],[x3,y0],[x3,y1]],
                      [[x3,y2],[x3,y3],[x2,y3] ]
                    ] )

# 0K倉庫
    x0 =  0.0 ; x1 = 1.5; x3 = x0 + 37.875 ; x2 = x3 - 1.5
    y0 =  0.0 ; y1 = 1.5; y3 = y0 + 26.175 ; y2 = y3 - 1.5 
    y4 = (y1+y2)*0.5-1.0  # x0 x1                              x2  x3
    y5 = (y1+y2)*0.5+1.0  #  +-------------------------------------+ y0
    x4 = x2 - 3.0         #  |                                     |
    x5 = x4 + 2.0         #  |  +-------------------------------+  | y1
                          #  |  |                               |  |
                          #  |  | y4                            |  |
                          #                                     |  |
                          #  |  | y5                            |  |
                          #  |  |                         x4  x5|  |
                          #  |  +--------------------------    -+  | y2
                          #  |                                     |
                          #  +-----------------------------    ----+ y3
                #
  AC0K = Ubr::Floor.
    new(:name => "0K", :id => 13,
        :walls   => [ [[x0,y4],[x0,y0],[x3,y0],[x3,y3],[x5,y3]],
                      [[x4,y3],[x0,y3],[x0,y5]],
                      [[x1,y4],[x1,y1],[x2,y1],[x2,y2],[x5,y2]],
                      [[x4,y2],[x1,y2],[x1,y5]]
                    ]
      )

  
  #### 
    x0 = 0.0 ; x1 = 45.7; x2 = x0 + 3.0 ; x3 = x2+2 ; x5 = x1 - 3.0;x4 = x5 -2
    y0 = 0.0 ; y1 = 28.5
                          # x0                                     x1
                          #  +-------------------------------------+ y0
                          #  |                                     |
                          #  |                                     |
                          #  |                                     |
                          #  |                                     |
                          #  |   x2  x3                   x4  x5   |
                          #  +----    ---------------------    ----+ y1
  AC0L =  Ubr::Floor.
    new(:name => "0L", :id => 14,
        :walls   => [ [[x2,y1],[x0,y1],[x0,y0],[x1,y0],[x1,y1],[x5,y1]],
                      [[x3,y1],[x4,y1]]
                    ]
      )
# 総合倉庫壁位置定数

                    xw=xc= 0; xa=6.165+6*7; x2=xa+6; x3l=x2+6*5;x3r=x3l+6; xe = 6.165+6*18+4.065
                             x1l = 25.156;x1r=x1l+4
                #    xw,xc             xa  x2             x3l  x3r        xe
  yn=ya = 0     #  yn +                 +   +--------------+    +----------+
                #             x1l,r    xp   |              |    |          |
  yc = 6        #  yc +--------  -------+---+              +-  -+          |
                #     |                 |                   x4             |
                #     |                 |                                  |
                #     |                 |                                  |
                #     |                 |                                  |
                #     |                 |                                  |
                #     |x4 xb         x8 |              x6      x5          |
  ys=y2 = 46.13 #  y2 +-  -+          +-+               +----  ------------+ ys
  yb = y2 + 1.3 #        yb+----------+                 |
                #          |          |                 |
  y3  = y2 + 10 #       x7 |          +-----------------+ y3
  y8 =90.7-10.25#      y8 +           |                 
                #         |   x9      |                 
  y4 = 90.7     #         +--  -------+ y4
                       x4 = xw+7.165 ;
                       x7=15.68;xb=x7+2.32; x8 =xb+30.33;x6=x8+29; x5=xe-4.065-25
                       x9= xb+5

Floors = { 
  "0A" =>   Ubr::Floor.
  new(:name       => "0A",:id => 9,
      :walls => [ [ [0,yc-ya],[x2-xa,yc-ya],[x2-xa,yn-ya],[x3l-xa,yn-ya],
                    [x3l-xa,yc-ya], [x3l-xa+1,yc-ya]], # NWから凹部左
                  [ [x3r-xa-1,yc-ya],[x3r-xa,yc-ya],[x3r-xa,yn-ya],          # 凹部から入口東
                    [xe-xa,0-ya],[xe-xa,y2-ya],[x5-xa,y2-ya]],  #N入口東から南入り口まで
                  [ [x5-4-xa,y2-ya],[x6-xa,y2-ya],[x6-xa,y3-ya],[x8-xa,y3-ya], # 南入り口から機材置き場SW
                    [x8-xa,y2-ya],  [xa-xa,y2-ya],[xa-xa,yc-ya]]               # 機材置き場SWから仕切り、エリアAのNW
                ]
      ),
  "0E" =>   Ubr::Floor.
  new(:name => "0E",:id => 11,
      :walls => [ [ [x9-4-xb,y4-yb],[x7-xb,y4-yb],            # 入り口左からSWでっぱり
                    [x7-xb,y8-yb],[xb-xb,y8-yb],[xb-xb,yb-yb], # 膨らみからNW
		    [x8-xb,yb-yb],[x8-xb,y4-yb],[x9-xb,y4-yb]]             # 東壁から入口
                ] 
      ),
  "0C" =>   Ubr::Floor.
  new(:name => "0C",:id => 10,
      :walls => [ [ [x1r-xc,yc-yc],[xa-xc,yc-yc],[xa-xc,y2-yc],[x8-xc,y2-yc], # 北入り口右からSE凹み
		    [x8-xc,yb-yc], [xb-xc,yb-yc],[xb-xc,y2-yc],[xb-5-xc,y2-yc]], # 南入り口まで
		  [ [xb-9-xc,y2-yc],[xw-xc,y2-yc],[xw-xc,yc-yc],[x1l-xc,yc-yc]]   # 南入り口左からN入り口左まで
                ]
      ),
  "1" => 
  Ubr::Floor.
    new(
        :name => "1",:id => 1,                         # 倉庫名
        :walls     =>[[[55,0],[90,0],[90,46.5],[63,46.5]],[[37,46.5],[0,46.5],[0,0]]   ]
        ),

    "2" =>Ubr::Floor.
    new(:name => "2", :id => 2, 
      :walls     => [[[0,30],[0,0],[50,0]],[[55,0],[90,0],[90,15]],[[90,19],[90,30]], 
                     Converator]
      ),

  "2-2" => Ubr::Floor.
    new( :name => "2-2",:id => 3, 
      :walls     => [[[0,30],[0,0],[90,0],[90,30],[0,30]] ,
                     Converator]
      ),

  "3" => Ubr::Floor.
      new(   :name => "3",:id => 4, 
             :walls     => [ [[0,32.5],[0,0],[5,0]],[[10.5,0],[39.5,0],[39.5,22.5]]] #,

      ),

  "4" => Ubr::Floor.
  new(:name => "4",  :id => 5, 
      :walls     => [ [[0,12],[0,0],[41,0],[41,12]],#4Hの蓋
                      [[0,16],[0,28]], [[41,16],[41,28]],[[0,22],[41,22]],  #4HGの境
                      [[0,32],[0,44],[41,44],[41,32]]   # 4Gの底
                    ]#, 
      ),
  "5-1" => Ubr::Floor.
  new( :name => "5-1",:id => 6, 
      :walls     => [ [[-0.35,12.4] ,[-0.35,-0.35],[94.85,-0.35],[94.85,12.4]],#5-1Fの蓋
                      [[30.35,-0.35],[30.35,12.4]],[[62.35,-0.35],[62.35,12.4]],# 境
                      [[30.35,30.35],[30.35,17.6]],[[62.35,30.35],[62.35,17.6]],
                      [[-0.35,17.6] ,[-0.35,30.35],[94.85,30.35],[94.85,17.6]]  # 底l

                  ]
      ),
  "5-2" => Ubr::Floor.
  new(:name => "5-2",:id => 7, 
      :walls     => [ [[-0.35,18.4] ,[-0.35,-0.35],[94.85,-0.35],[94.85,12.4]],#5-1Fの蓋
                      [[30.35,-0.35],[30.35,12.4]],[[62.35,-0.35],[62.35,12.4]],# 境
                      [[30.35,30.35],[30.35,17.6]],[[62.35,30.35],[62.35,17.6]],
                      [[-0.35,23.6] ,[-0.35,30.35],[94.85,30.35],[94.85,12.4]]  # 底
                  ]
      ),
  "6" =>  Ubr::Floor.
  new(:name => "6",:id => 8, 
      :walls     => [ [[0,7.75] ,[0,0],[33,0],[33,6]],#6の蓋
                      [[0,12.25],[0,20],[33,20],[33,14]]   # 6の底
      ]
      ) ,
     "0J" => AC0J,
    "0K" => AC0K,
    "0L" => AC0L
}

SSP =[
     { :name => "123倉庫",
       :offset     =>[20,5] ,                              # 用紙左上から建物基準点までの mm
       :floor_offset => { "1" => [0,62.5], "2" => [0,32.5],"3" => [45,0], "2-2" => [0,113] },
       :stat_names   => %w(1A 1B 2 3 2-2F),
       :stat_reg     => [/^1A/,/^1B/,/^2[CD]/,/^3/,/^2E/],
       :stat_offset  => [5,10],:stat_font=> [1,0,0]
     },
     { :name   => "456倉庫",
       :offset =>[10,10] , 
       :floor_offset => { "4" => [53.8,90],"5-1" => [0,55],"5-2" => [0,20],"6" => [0,90]},
       :stat_names   => %w(4 5 6 5-2F),
       :stat_reg     => [/^4/,/^5[JIK]/,/^6/,/^5[LMN]/],
       :stat_offset  => [10,7],:stat_font=> [1,0,0]
     },
     { :name => "総合倉庫",:landscape => true,
       :offset     =>[25,25] ,                              # 用紙左上から建物基準点までの mm
       :floor_offset => { "0A" => [xa,ya], "0E" => [xb,yb], "0C" => [xc,yc]},
       :stat_names   => %w(0A 0B 0C 0D 0E 野積),
       :stat_reg     => [/^0A/,/^0B/,/^0C/,/^0D/,/^0E/,/^7/],
       :stat_offset  => [60,60],:stat_font=> [1,1,0]
     }
   # { :name => "AP跡",:landscape => true,
   #   :offset     =>[25,25] ,                              # 用紙左上から建物基準点までの mm
   #   :floor_offset => { "0K" => [0,0], "0L" => [0,50]},
   #   :stat_names   => %w(0L 0L),
   #   :stat_reg     => [/^0K/,/^0L/],
   #   :stat_offset  => [60,60],:stat_font=> [1,1,0]
   # }
   ]

end
__END__
require 'pp'
Ubr::Const::SP.each{ |h| pp [[h[:name],h[:offset],h[:stat_offset]],h[:stat_names],h[:stat_reg]]}
$Floors.keys.sort
k.each{ |souko| f=$Floors[souko]; f.contents.each_with_index{|c,i| pp [souko,c,f.sufix[i],f.max[i],f.base_points[i][0],f.base_points[i][1],f.label_pos[i][0],f.label_pos[i][1]] }}

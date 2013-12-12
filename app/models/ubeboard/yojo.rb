# -*- coding: utf-8 -*-
require 'pp'
# 養生庫の管理を行うクラス。ARではない。CVもない
# <tt>:next_start</tt>;;この養生庫が次に開始可能となる日時
# <tt>:assign</tt>;;:next_start からYojoTime時間を割り当てたとし、:next_startをYojoTime時間進める。
#     ただし、この養生庫の保守が入っていて、それがYojoTime時間後からYojoTime時間の間に
#     重なる場合は、保守終了予定時間を:next_startにする。
class Ubeboard::Yojo

  YojoTime = 40.hour

  #養生庫はNo2～No24
  Yojoko   = Hash[*[
                    [ 2..6 ,1.0],   # 養生庫はNo2～No6 の容量は基準量
                    [ 7..12 ,0.75],
                    [ 13..18 ,1.0],
                    [ 19..24 ,1.25]
                   ].map{|range,rate|  range.map{|no| [no,rate] }}.flatten]

  # UbeSkdで、立案するときにインスタンスが養生庫分生成される。
  def initialize(no)
    raise unless Yojoko.include?(no)
    @no = no
    @size = Yojoko[@no]
  end

  def name ;"養生庫-#{no}" ;end
  def size ;@size;end
  def no   ;@no  ;end
  def plan ;@plan;end

  def <=>(other)
   # case other.class
    #when UbeYojo ; 
      self.next_start <=> other.next_start
    #when Time    ; self.next_start <=> other
    #else         ; raise
    #end
  end

  # アサインされると :next_start を進めることで、割り当てたことになる。
  # 次の開始時刻は、乾燥が終わるとき。
  # <tt>dry_stop</tt>;;乾燥が終わる時刻。省略時は @planから読む
  def assign(assigned_plan,dry_stop=nil)
    # 新しいnext_timeから養生時間までの間にある保守がある場合はさらにずらす
    # 　保守を探す next_time <= 保守終了 保守開始 <= next_time + YojoTime
    @plan=assigned_plan
    dry_stop ||=  @plan.plans(:dry,:plan_end)
    #養生庫があく時間。== 乾燥終了時刻。
    #  乾燥がアサインされていなければ 
    #      養生終了時刻 + 30時間(乾燥時間+乾燥前余裕）
    #　　もしくは 養生開始時刻 + YojoTime　+ 30時間(乾燥時間+乾燥前余裕）
    next_time = dry_stop ? dry_stop :  next_start + YojoTime + 30.hour
    next_start(next_time)
  end

  # 次に利用可能になる日時を設定する。
  # 日時がしていされなかった場合は、立案期間の最初から使えるものとする
  #     UbeSkd での初期化ではそうなる
  # 利用可能日時から40時間(養生時間)以内に休転がある場合は、それが終わる所まで
  # 遅らせる。
  def next_start(datetime=nil)
    unless @next_start
      @next_start = nil
    end
    if datetime
      maintain = 
        Ubeboard::Maintain.where(["ope_name=? and plan_time_start <= ? and plan_time_end>=?",
                                       name,datetime,datetime+YojoTime
                                      ]
                         )
      @next_start = maintain.size>0 ? maintain.map(&:plan_time_end).sort[-1] : datetime
    end
    @next_start
  end
end

__END__
$Id: ube_yojo.rb,v 2.4 2012-10-16 08:49:11 dezawa Exp $
$Log: ube_yojo.rb,v $
Revision 2.4  2012-10-16 08:49:11  dezawa
ruby9仕様のために、codingを1行目に入れた

Revision 2.3  2012-03-20 08:22:29  dezawa
Rdoc0_1

Revision 2.2.2.1  2012-03-18 08:05:03  dezawa
*** empty log message ***

Revision 2.2  2012-03-04 10:37:37  dezawa
メンテナンスをユーザオプションで管理することにした

Revision 2.1  2012-03-04 09:30:07  dezawa
養生庫の休転確認のタイミングがまずかった

Revision 2.0  2012-01-29 23:31:37  dezawa
リリース版：最適化一旦ここまで。
BUG出しに移る

Revision 1.12  2011-12-24 08:27:22  dezawa
型板は乾燥無し、の割付

Revision 1.11  2011-11-25 04:02:23  dezawa
2011/11/12 仮リリース

Revision 1.10  2011-11-13 13:25:12  dezawa
2011-11-09の打ち合わせによる
64,66 67 69 70 71 73 74 75 76 78

Revision 1.9  2011-09-19 07:33:10  dezawa
乾燥はオーバーラップをトランクに

Revision 1.8.6.2  2011-09-19 04:50:33  dezawa
乾燥のオーバーラップBugFix

Revision 1.8.6.1  2011-09-18 05:03:04  dezawa
乾燥の終了を投入終了と完了に分けた。

Revision 1.8  2011-08-25 12:19:13  dezawa
RDoc化進行中

Revision 1.7  2011-08-18 00:36:51  dezawa
/opt移動

Revision 1.6  2011-08-13 03:11:24  dezawa
ひとまず完成。55 55.3-55.5 58 92

Revision 1.5  2011-08-05 21:17:58  dezawa
問懸 75 44 77 80 43 42 65 67.3

Revision 1.4  2011-08-03 14:40:35  dezawa
UbeYojoの割り振りまでできた

Revision 1.3  2011-08-03 14:05:39  dezawa
UbeYojo準備した

Revision 1.2  2011-08-02 22:05:25  dezawa
ほぼ良くなったが、移動が正しくない

Revision 1.1  2011-07-31 10:29:17  dezawa
新規作成


# -*- coding: utf-8 -*-
require 'test_helper'

class ForecastTest < ActiveSupport::TestCase

Maebashi = 
"20.0	19.0	22.0	94
27.6	17.2	19.6	53
23.1	21.2	25.2	89
10.8	0.0	6.1	47
4.5	0.8	6.5	77
25.7	23.2	28.4	86
-2.6	-11.3	2.6	51
".split(/[\n\r]+/).map{ |l| l.split.map(&:to_f)}

  def setup
    @forecast = Forecast.new
    @lines    = File.read(RAILS_ROOT+"/test/testdata/forecast_tenki").split(/[\n\r]+/)
  end

  must "Maebashi =" do
    Maebashi.each{ |tdvp| temp,dew,vaper,humi = tdvp
      assert_equal vaper,@forecast.vaper_presser(temp,humi).round(1),"#{tdvp.join(',')}"
    }
  end

  must "天気.jp アナウンス日" do
    assert_equal Time.local(2014,7,26,7,0),Forecast.announce_datetime(@lines)
  end
  must "天気.jp 今日、明日の日付" do
    Forecast.announce_datetime(@lines)
    assert_equal Date.new(2014,7,26),Forecast.today_is(@lines)
    assert_equal Date.new(2014,7,27),Forecast.tomorrow_is(@lines)
  end
  must "天気.jp 雨" do
    Forecast.announce_datetime(@lines)
    Forecast.today_is(@lines)
    Forecast.tomorrow_is(@lines)
    Forecast.hour_lines(@lines)
    assert_equal %w(曇り 曇り 曇り 晴れ 晴れ 晴れ 晴れ 晴れ
                    晴れ 晴れ 晴れ 晴れ 曇り 晴れ 晴れ 晴れ),Forecast.rain_rank(@lines)
  end
  must "天気.jp 気温" do
    Forecast.announce_datetime(@lines)
    Forecast.today_is(@lines)
    Forecast.tomorrow_is(@lines)
    Forecast.hour_lines(@lines)
    Forecast.rain_rank(@lines)
    assert_equal [26.9, 26.4, 27.8, 34.2, 36.3, 33.4, 30.4, 28.3,
                  26.9, 26.1, 30.2, 35.0, 34.6, 31.8, 28.8, 26.4],Forecast.temperaures(@lines)
  end

  must "Tommow data " do
    today = Time.now.to_date
    tomorrow = today + 1
    assert_equal nil,Forecast.find_by_location_and_date_and_announce_day(:maebashi.to_s,tomorrow,today )
    Forecast.fetch(:maebashi,tomorrow)
    tomorrow_fore = Forecast.find_by_location_and_date_and_announce_day(:maebashi.to_s,tomorrow,today )
    assert_equal Time.now,tomorrow_fore.announce
  end
end
__END__
!-- component/forecast/template/point_10201.html ## generate at 2014-07-23 12:07:56 -->
!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
html xmlns="http://www.w3.org/1999/xhtml" xmlns:og="http://ogp.me/ns#" xmlns:fb="http://www.facebook.com/2008/fbml" lang="ja" xml:lang="ja">
head>
meta http-equiv="Content-Type" content="text/html;charset=utf-8">
title>前橋市のピンポイント天気 - 日本気象協会 tenki.jp
/title>
meta http-equiv="X-UA-Compatible" content="IE=edge">
meta name="keywords" content="天気,天気予報,tenki.jp,災害">
meta name="description" content="群馬県 前橋市のピンポイント天気。3時間毎に最大48時間先までの天気・気温・降水量・風向・風速・湿度の予測と、10日間の天気予報が確認できます。">
meta http-equiv="Content-Style-Type" content="text/css">
meta http-equiv="Content-Script-Type" content="text/javascript">
meta http-equiv="imagetoolbar" content="no">
link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
link rel="apple-touch-icon-precomposed" href="http://az416740.vo.msecnd.net/images/lite/bookmark/tenkijp_bookmark_icon_114_114.png">
meta property="og:type" content="website">
meta property="og:site_name" content="tenki.jp">
meta property="og:title" content="前橋市のピンポイント天気 - tenki.jp">
meta property="og:description" content="群馬県 前橋市のピンポイント天気。3時間毎に最大48時間先までの天気・気温・降水量・風向・風速・湿度の予測と、10日間の天気予報が確認できます。">
meta property="og:url" content="http://www.tenki.jp/forecast/3/13/4210/10201.html">
meta property="og:image" content="http://az416740.vo.msecnd.net/images/lite/bookmark/tenkijp_bookmark_icon_228_228.png">
meta name="mixi-check-robots" content="nodescription, noimage, ignoreimage">
link rel="alternate" media="only screen and (max-width: 640px)" href="http://www.tenki.jp/lite/forecast/3/13/4210/10201.html">
link rel="stylesheet" href="/css/contents/common.min.css?20140701">
script async="" type="text/javascript" src="//dex.advg.jp/dx/p/sync?_aid=1229&amp;_page=1137">
/script>
script async="" type="text/javascript" src="//m.dtpf.jp/dx/mark?_cid=17&amp;_pid=1&amp;_url=http%3A//www.tenki.jp/forecast/3/13/4210/10201.html&amp;_ref=&amp;_nc=140633020957178482906">
/script>
script type="text/javascript" async="" src="http://c.nakanohito.jp/b3/bi.js">
/script>
script async="" type="text/javascript" src="http://www.gstatic.com/pub-config/ca-tenki-site_html.js">
/script>
script type="text/javascript" async="" src="http://www.google-analytics.com/ga.js">
/script>
script type="text/javascript">
!-- /*@cc_on _d=document;eval('var document=_d')@*/ -->
/script>
script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js">
/script>
script type="text/javascript">var __point_name = "前橋市"; var __point_code = "forecast_10201"; var __point_permalink = "http://www.tenki.jp/forecast/3/13/4210/10201.html";
/script>

script type="text/javascript" src="/js/contents.min.js?20140701">
/script>

script type="text/javascript">
!--
if(__b && __b[0]) {
  var __css = document.createElement("link");
  __css.setAttribute("rel","stylesheet");
  __css.setAttribute("type","text/css");
  __css.setAttribute("href","/css/contents/forecast_table_1h.css");
  document.getElementsByTagName("head")[0].appendChild(__css);
}
// -->
/script>


script type="text/javascript">
!--
$(function(){
  if( navigator && navigator.userAgent && navigator.userAgent.match(/(Android|iPod|iPhone)/) ) {
    $('#ft').prepend('
div style="margin:auto; margin-top:10px; padding:5px; width:400px; border:1px solid #CCC; background-color:#EEE; text-align:center;">
span>表示：
/span>
span>
a href="#" id="pc_to_lite_link">スマートフォン
/a>
/span>
span>｜
/span>
span>PC
/span>
/div>');
    $('#pc_to_lite_link').click(function(){
      var datetime = new Date();
      datetime.setYear(datetime.getYear() - 1);
      document.cookie = 'viewmode=;' + 'expires=' + datetime.toUTCString() + ';domain=' + 'tenki.jp' + ';path=/;';
      location.href = 'http://www.tenki.jp/lite/forecast/3/13/4210/10201.html';
      return false;
    });
  }
});
// -->
/script>
script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-6021470-2']);
  _gaq.push(['_setDomainName', 'tenki.jp']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

/script>

!-- for 天気予報・ピンポイント天気 PD1/PD2 -->
!-- 2013/08/30 for PD1/PD2 群馬 -->
script type="text/javascript">
(function() {
var useSSL = 'https:' == document.location.protocol;
var src = (useSSL ? 'https:' : 'http:') +
'//www.googletagservices.com/tag/js/gpt.js';
document.write('
scr' + 'ipt src="' + src + '">
/scr' + 'ipt>');
})();
/script>
script src="http://www.googletagservices.com/tag/js/gpt.js">
/script>

script type="text/javascript">
googletag.defineSlot('/11384922/1st_PD_point_gunma', [[300, 250], [300, 600]], 'div-gpt-ad-1377771504626-0').addService(googletag.pubads());
googletag.defineSlot('/11384922/2nd_PD_forecast', [300, 250], 'div-gpt-ad-1377771504626-1').addService(googletag.pubads());
googletag.pubads().enableSyncRendering();
googletag.pubads().enableSingleRequest();
googletag.enableServices();
/script>
script type="text/javascript" src="http://partner.googleadservices.com/gpt/pubads_impl_45.js">
/script>
!-- /2013/08/30 for PD1/PD2 群馬 -->
!-- /for 天気予報・ピンポイント天気 PD1/PD2 -->

script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/osd.js">
/script>
/head>
body style="">

!-- ClickTale Top part -->
script type="text/javascript">
var WRInitTime=(new Date()).getTime();
/script>
!-- ClickTale end of Top part -->

!-- #container -->
div id="container" class="container">

!-- #hd  -->
!-- #hd  -->
div id="hd" class="clearfix">
  
div id="masthead">
a href="http://www.tenki.jp/">tenki.jp
/a>
/div>
  
div id="hd_account">
    
script type="text/javascript">
        if(__b && __b[0]) {
            if(__b[1]) {
                document.write('
a href="https://cms.tenki.jp/cms/member/logout/">
img src="' + __b[1] +'" width="20" height="20" alt="ログアウト" />
/a>
a href="https://cms.tenki.jp/cms/member/logout/">ログアウト
/a>');
            } else {
                document.write('
a href="https://cms.tenki.jp/cms/member/logout/">
img src="https://az416740.vo.msecnd.net/images/icon/icon_account_noimage.png" width="20" height="20" alt="ログアウト" />
/a>
a href="https://cms.tenki.jp/cms/member/logout/">ログアウト
/a>');
            }
        } else {
            var current_url = location.href;
            current_url = __escapeHTML(current_url);
            current_url = escape(current_url);
            document.write('
a href="https://cms.tenki.jp/cms/member/login/?.done=' + current_url + '">
img src="https://az416740.vo.msecnd.net/images/icon/icon_account_login.png" width="20" height="20" alt="ログイン" />
/a>
a href="https://cms.tenki.jp/cms/member/login/?.done=' + current_url  + '">ログイン
/a>');
        }
    
/script>
a href="https://cms.tenki.jp/cms/member/login/?.done=http%3A//www.tenki.jp/forecast/3/13/4210/10201.html">
img src="https://az416740.vo.msecnd.net/images/icon/icon_account_login.png" width="20" height="20" alt="ログイン">
/a>
a href="https://cms.tenki.jp/cms/member/login/?.done=http%3A//www.tenki.jp/forecast/3/13/4210/10201.html">ログイン
/a>
    
/div>
!-- /#hd_account -->
        
  
div id="hd_help">
a href="http://www.tenki.jp/" class="bold">tenki.jpトップ
/a>
span class="grey">｜
/span>
a href="/help/">ヘルプ
/a>
/div>
/div>
!-- /#hd  -->

div id="search" class="clearfix">
    
    
div id="search_box" class="search_box_long">
        
form id="search-form" name="search-form" method="get" action="http://www.tenki.jp/search/zip/">
            
input value="" name="keyword" type="text" class="search_input" id="keyword" placeholder="〒・住所を入力">
button type="submit" value="検索" id="btn" tabindex="2" title="検索">検索
/button>
        
/form>
    
/div>
    
div id="search_gps_btn" class="search_gps_long">
        
a href="javascript:void(0);">現在地で検索
/a>
    
/div>
  
div id="search_clip" class="clearfix">
ul id="clip_detail_forecast_10201" class="clip_detail">
li id="clip_detail_weather_forecast_10201" class="clip_detail_weather">
a href="/forecast/3/13/4210/10201.html" title="前橋市の天気(曇のち晴)">
img src="//az416740.vo.msecnd.net/images/icon/weatherIcon/12.gif">
/a>
/li>
li id="clip_detail_text_forecast_10201" class="clip_detail_text">
a href="/forecast/3/13/4210/10201.html" title="前橋市の天気(曇のち晴)">前橋市
br>
span class="clip_temp_max">37
/span>/
span class="clip_temp_min">26
/span>
/a>
/li>
li id="clip_detail_delete_forecast_10201" class="clip_detail_delete">
a href="javascript:void(0);">
img src="//az416740.vo.msecnd.net/images/icon/btn_clip_delete.png" width="13" height="13" alt="削除">
/a>
/li>
/ul>
/div>
/div>
!-- /#search -->

script type="text/javascript">
!--
var ua, isIE, isFF;
ua = window.navigator.userAgent.toLowerCase();

isIE = (ua.indexOf('msie') >= 0 || ua.indexOf('trident') >= 0);
isFF = (ua.indexOf('firefox') >= 0);

if (isIE || isFF || navigator.geolocation == undefined) {
    document.write('
style>#search_gps_btn{display:none}
/style>');
    $('#search_box').attr('class', 'search_box_long');
} else {

    $('#keyword').focus( function () { 
        $('#search_box').attr('class', 'search_box_long');
        $('#search_gps_btn').attr('class', 'search_gps_short');
    } );

    $('#keyword').blur( function () { 
        setTimeout(function() {
            $('#search_box').attr('class', 'search_box_short'); 
                $('#search_gps_btn').attr('class', 'search_gps_long');
            }, 300);
    } );
}

$('#search-form').submit(function(){
  var $keyword = $('#search-form > #keyword');
  if($keyword && $keyword.val() == '') {
      $keyword.attr('placeholder','検索ワードを入力して下さい').focus();
      setTimeout(function(){
        $('#search-form > #keyword').attr('placeholder','〒・住所を入力');
        $keyword.trigger( "focus" );
      },1000);
      return false;
  }
  return true;
});


// -->
/script>
style>#search_gps_btn{display:none}
/style>
script type="text/javascript">
!--
// get GPS redirect to point_url
$(function(){
  if(document.getElementById('search_gps_btn')) {
    $('#search_gps_btn').click(function(e){
     if(navigator.geolocation == undefined) {
        alert('位置情報が利用できません');
        return false;
      }
      navigator.geolocation.getCurrentPosition(
        function(position) { // sccess
            var json_url = '/api/lite/search/geo/?lat=' + position.coords.latitude + '&lon=' + position.coords.longitude + '&time=' + (new Date).getTime();
            var redirect_url;
            $.getJSON(
                json_url,
                null,
                function(data, status) {
                    if (data == undefined || data.permalink == undefined) {
                        alert('位置情報を取得できません');
                        return false;
                    }
                    window.location = data.permalink;
                    return false;

                }
            );
            return false;
        },function(err) { // error
            alert("位置情報が利用できません(" + err.code + ")" + err.message);
        }
      );
      return false;
    });
  }
});
// -->
/script>


div id="menu">
    
ul id="menu_main" class="clearfix">
        
li class="selected">
          
a href="/">天気予報
/a>
          
ul id="menu_sub" class="clearfix">
            
li class="selected">
a href="/">天気予報
/a>
/li>
            
li>
a href="/world/">世界天気
/a>
/li>
            
li>
a href="/forecaster/diary/">日直予報士
/a>
/li>
            
li>
a href="/long/">長期予報
/a>
/li>
            
li>
a href="/radar/rainmesh.html">雨雲の動き(予報)
/a>
/li>
            
li>
a href="/particulate_matter/">PM2.5分布予測
/a>
/li>
            
li class="recommend">
span>おすすめ！
/span>
a href="/heatstroke/">熱中症情報
/a>
/li>
          
/ul>
!-- /#menu_sub -->
        
/li>
        
li>
          
a href="/radar/">観測
/a>
          
ul id="menu_sub" class="clearfix">
            
li>
a href="/radar/">雨雲の動き(実況)
/a>
/li>
            
li>
a href="/amedas/">アメダス
/a>
/li>
            
li>
a href="/live/">実況天気
/a>
/li>
            
li>
a href="/past/">過去天気
/a>
/li>
            
li class="recommend">
span>おすすめ！
/span>
a href="/heatstroke/">熱中症情報
/a>
/li>
          
/ul>
!-- /#menu_sub -->
        
/li>
        
li>
          
a href="/bousai/warn/">防災情報
/a>
          
ul id="menu_sub" class="clearfix">
            
li>
a href="/bousai/warn/">警報・注意報
/a>
/li>
            
li>
a href="/bousai/earthquake/">地震情報
/a>
/li>
            
li>
a href="/bousai/tsunami/">津波情報
/a>
/li>
            
li>
a href="/bousai/volcano/">火山情報
/a>
/li>
            
li>
a href="/bousai/typhoon/">台風情報
/a>
/li>
            
li class="recommend">
span>おすすめ！
/span>
a href="/heatstroke/">熱中症情報
/a>
/li>
          
/ul>
!-- /#menu_sub -->
        
/li>
        
li>
          
a href="/guide/chart/">天気図
/a>
          
ul id="menu_sub" class="clearfix">
            
li>
a href="/chart/">天気図
/a>
/li>
            
li>
a href="/satellite/">気象衛星
/a>
/li>
            
li>
a href="/satellite/world/">世界衛星
/a>
/li>
            
li class="recommend">
span>おすすめ！
/span>
a href="/heatstroke/">熱中症情報
/a>
/li>
          
/ul>
!-- /#menu_sub -->
        
/li>
        
li>
          
a href="/indexes/cloth_dried/">指数情報
/a>
          
ul id="menu_sub" class="clearfix">
            
li class="menu_sub_type">通年
/li>
            
li>
a href="/indexes/cloth_dried/">洗濯
/a>
/li>
            
li>
a href="/indexes/dress/">服装
/a>
/li>
            
li>
a href="/indexes/odekake/">お出かけ
/a>
/li>
            
li>
a href="/indexes/starry_sky/">星空
/a>
/li>
            
li>
a href="/indexes/umbrella/">傘
/a>
/li>
            
li>
a href="/indexes/uv_index_ranking/">紫外線
/a>
/li>
            
li>
a href="/indexes/self_temp/">体感温度
/a>
/li>
            
li>
a href="/indexes/carwashing/">洗車
/a>
/li>
            
li>
a href="/indexes/leisure/">レジャー
/a>
/li>
            
li>
a href="/indexes/throat_lozenge/">のど飴
/a>
/li>
            
li class="recommend">
span>おすすめ！
/span>
a href="/heatstroke/">熱中症情報
/a>
/li>
          
/ul>
!-- /#menu_sub -->
          
ul id="menu_sub2" class="menu-sub clearfix">
            
li class="menu_sub_type">夏季
/li>
            
li>
a href="/indexes/sweat/">汗かき
/a>
/li>
            
li>
a href="/indexes/discomfort/">不快
/a>
/li>
            
li>
a href="/indexes/reibo/">冷房
/a>
/li>
            
li>
a href="/indexes/ice_cream/">アイス
/a>
/li>
            
li>
a href="/indexes/beer/">ビール
/a>
/li>
            
li>
a href="/indexes/disinfect/">除菌
/a>
/li>          
/ul>
!-- /#menu_sub2 -->
                  
/li>
        
li>
          
a href="/mountain/">レジャー天気
/a>
          
ul id="menu_sub" class="clearfix">
            
li>
a href="/mountain/">山の天気
/a>
/li>
            
li>
a href="/wave/">海の天気
/a>
/li>
            
li>
a href="/leisure/airport/">空港
/a>
/li>
            
li>
a href="/leisure/baseball/">野球場
/a>
/li>
            
li>
a href="/leisure/soccer/">サッカー場
/a>
/li>
            
li>
a href="/leisure/golf/">ゴルフ場
/a>
/li>
            
li>
a href="/leisure/camp/">キャンプ場
/a>
/li>
            
li>
a href="/leisure/horse/">競馬・競艇・競輪場 
/a>
/li>
            
li>
a href="/leisure/fishing/">釣り
/a>
/li>
            
li>
a href="/leisure/park/">テーマパーク
/a>
/li>
            
li class="recommend">
span>おすすめ！
/span>
a href="/heatstroke/">熱中症情報
/a>
/li>
          
/ul>
!-- /#menu_sub -->
        
/li>
        
li>
          
a href="/heatstroke/">季節特集
/a>
          
ul id="menu_sub" class="clearfix">            
li>
a href="/heatstroke/">熱中症情報
/a>
/li>
            
li class="recommend">
span>おすすめ！
/span>
a href="/heatstroke/">熱中症情報
/a>
/li>
          
/ul>
!-- /#menu_sub -->
        
/li>
        
li>
          
a href="/labo/">tenki.jpラボ
/a>
          
ul id="menu_sub" class="clearfix">
            
li>
a href="/labo/">tenki.jpラボ
/a>
/li>
            
li class="recommend">
span>おすすめ！
/span>
a href="/heatstroke/">熱中症情報
/a>
/li>
          
/ul>
!-- /#menu_sub -->
        
/li>
    
/ul>
!-- /#menu_main -->
/div>
!-- /#menu -->

script type="text/javascript">
!--
var __timer = '';
$('#menu_main > li').hover(
  function () {
    if(__timer) { clearTimeout(__timer); }
    var $$ = $(this);
    if($$.hasClass('selected')) {
        $('#menu_main > li:not(.selected) > ul').css("display","none");
        $('ul',this).css("display","block");
    } else {
        $('#menu_main > li > ul').css("display","none");
        $('ul',this).css("display","block");
    }
  },
  function () {
    var $$ = $(this);
    if($$.hasClass('selected')) {
        $('#menu_main > li:not(.selected) > ul').css("display","none");
    } else {
        $('ul',this).css("display","block");
    }
    __timer = setTimeout(function(){
        var $$ = $('#menu_main > li.selected > ul');
        if($$ && !$$.is(':visible')) {
          $('#menu_main > li:not(.selected) > ul').css("display","none");
          $$.fadeIn("fast");
        }
    },2000);
  }
);
// -->
/script>

!-- #delimiter -->
div id="delimiter">
  
p>
a href="/">トップ
/a>&nbsp;&gt;&nbsp;
a href="/forecast/3/">関東・甲信地方
/a>&nbsp;&gt;&nbsp;
a href="/forecast/3/13/">群馬県
/a>&nbsp;&gt;&nbsp;
a href="/forecast/3/13/4210.html">南部(前橋)
/a>&nbsp;&gt;&nbsp;前橋市
/p>
/div>
!-- /#delimiter -->


ul class="wideBtn">
li>
!-- Begin: Adlantis -->
!-- Adlantis Zone: [ワイドボタン2] -->
script type="text/javascript">
var Adlantis_Title_Color = '0000FF';
var Adlantis_Text_Color = '000000';
var Adlantis_Background_Color = 'F9F9F9';
var Adlantis_Border_Color = '999999';
var Adlantis_URL_Color = '008000';
/script>
script src="http://ad.adlantis.jp/ad/load_ad?zid=8QHQyiGUw14Aanco%2BtKX1A%3D%3D&amp;s=-1&amp;t=1" type="text/javascript" charset="utf-8">
/script>
!-- End: Adlantis -->
/li>
li>
!-- 飯南町_ワイドボタン -->
!-- Begin: Adlantis -->
!-- Adlantis Zone: [ワイドボタン1] -->
script type="text/javascript">
var Adlantis_Title_Color = '0000FF';
var Adlantis_Text_Color = '000000';
var Adlantis_Background_Color = 'F9F9F9';
var Adlantis_Border_Color = '999999';
var Adlantis_URL_Color = '008000';
/script>
script src="http://ad.adlantis.jp/ad/load_ad?zid=LmxUEEMSC8mz77SYD2uujA%3D%3D&amp;s=-1&amp;t=1" type="text/javascript" charset="utf-8">
/script>
iframe scrolling="no" allowtransparency="true" frameborder="0" hspace="0" vspace="0" marginwidth="0" marginheight="0" width="176" height="31" src="http://ad.adlantis.jp/ad/show?s=-1&amp;zid=LmxUEEMSC8mz77SYD2uujA%3D%3D&amp;title_color=0000FF&amp;text_color=000000&amp;bg_color=F9F9F9&amp;border_color=999999&amp;url_color=008000&amp;ref=&amp;magic=gvclbcrnof">
/iframe>
!-- End: Adlantis -->
!-- /飯南町_ワイドボタン -->
/li>
/ul>
!-- #header_text -->
div id="ad_header_text">[PR]&nbsp;
a href="http://www.tenki.jp/heatstroke/special2014/">熱中症対策特集　子どもの熱中症対策のポイント
/a>
/div>
!--/header_text-->
!-- /#header_text -->
script type="text/javascript">
!--
var header_text_pr_entries = [
        {
            'pr_txt'     : '熱中症対策特集　子どもの熱中症対策のポイント',
            'permalink'  : 'http://www.tenki.jp/heatstroke/special2014/'
        },
        {
            'pr_txt'     : '熱中症対策特集　衣服の工夫による熱中症対策のポイントとは?',
            'permalink'  : 'http://www.tenki.jp/heatstroke/docs/triumph'

        },
        {
            'pr_txt'     : '夏の紫外線対策特集　紫外線についての正しい知識と対処法',
            'permalink'  : 'http://www.tenki.jp/docs/uv_special2014'
        }
    ];
    var n = Math.floor(Math.random() * header_text_pr_entries.length);
    document.getElementById('ad_header_text').innerHTML = '[PR]&nbsp;
a href="' + header_text_pr_entries[n]['permalink'] + '">' + header_text_pr_entries[n]['pr_txt'] + '
/a>';
// -->
/script>



!-- #center_text -->
div id="center_text_wrap" class="clearfix">
script async="" src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js">
/script>
ins class="adsbygoogle" style="display:inline-block;width:915px;height:60px" data-ad-client="ca-tenki-site_html" data-ad-channel="center_txt" data-ad-type="text" data-max-num-ads="2" data-language="ja" data-override-format="true" data-adsbygoogle-status="done">
ins style="display:inline-table;border:none;height:60px;margin:0;padding:0;position:relative;visibility:visible;width:915px;background-color:transparent">
ins id="aswift_0_anchor" style="display:block;border:none;height:60px;margin:0;padding:0;position:relative;visibility:visible;width:915px;background-color:transparent">
iframe width="915" height="60" frameborder="0" marginwidth="0" marginheight="0" vspace="0" hspace="0" allowtransparency="true" scrolling="no" allowfullscreen="true" onload="var i=this.id,s=window.google_iframe_oncopy,H=s&amp;&amp;s.handlers,h=H&amp;&amp;H[i],w=this.contentWindow,d;try{d=w.document}catch(e){}if(h&amp;&amp;d&amp;&amp;(!d.body||!d.body.firstChild)){if(h.call){setTimeout(h,0)}else if(h.match){try{h=s.upd(h,i)}catch(e){}w.location.replace(h)}}" id="aswift_0" name="aswift_0" style="left:0;position:absolute;top:0;">
/iframe>
/ins>
/ins>
/ins>
script>
(adsbygoogle = window.adsbygoogle || []).push({});
/script>
/div>
!-- /#center_text -->


div id="bd">
!--  #bd  -->

script type="text/javascript">var random=new Date();document.write('
scr' + 'ipt src="' + '/component/static_api/forecast_point/table/' + 42251 + '.js?' + random.getTime() +'">
/scr' + 'ipt>');
/script>
script src="/component/static_api/forecast_point/table/42251.js?1406330206557">
/script>
!-- point_table.inc 42251 ## generate at 2014-07-26 08:03:17 -->
div class="contentsBox">
div class="titleBorder">  
div class="titleBgLong">    
h2 id="pinpoint_weather_name">前橋市の天気
/h2>    
div class="dateRight" id="point_announce_datetime">2014年07月26日07:00発表
/div>  
/div>
/div>
table id="leisurePinpointWeather" summary="ピンポイント天気">
thead>
tr class="head">  
th abbr="日付">日付
/th>  
td colspan="8">    
div>    
p>今日 07月26日(土)
span class="rokuyoh">[大安]
/span>
/p>    
/div>  
/td>  
td colspan="8">    
div>    
p>明日 07月27日(日)
span class="rokuyoh">[先勝]
/span>
/p>    
/div>  
/td>
/tr>
/thead>
tbody>
tr class="date">  
th abbr="時間" rowspan="2">時間
/th>  
td colspan="4">
span>午前
/span>
/td>  
td colspan="4">
span>午後
/span>
/td>  
td colspan="4">
span>午前
/span>
/td>  
td colspan="4">
span>午後
/span>
/td>
/tr>
tr class="hour">
td>
span class="past">03
/span>
/td>
td>
span class="past">06
/span>
/td>
td>
span>09
/span>
/td>
td>
span>12
/span>
/td>
td>
span>15
/span>
/td>
td>
span>18
/span>
/td>
td>
span>21
/span>
/td>
td>
span>24
/span>
/td>
td>
span>03
/span>
/td>
td>
span>06
/span>
/td>
td>
span>09
/span>
/td>
td>
span>12
/span>
/td>
td>
span>15
/span>
/td>
td>
span>18
/span>
/td>
td>
span>21
/span>
/td>
td>
span>24
/span>
/td>
/tr>
tr class="weather">
th abbr="天気">天気
br>
span id="help_forecast_point_1">
img src="http://az416740.vo.msecnd.net/images/contents/heatstroke/icon_help.gif" width="15" height="14" alt="" title="">
/span>
p id="help_forecast_point_text_1">※モノクロ表示は、過去の予報値です。
br>※雨のランクは5段階で表示されます。
br>　小雨　0mm/h
br>　弱雨　1～3mm/h
br>　雨　　4～10mm/h
br>　強雨　11～20mm/h
br>　豪雨　21mm/h以上
/p>
/th>
td>
img width="33" height="30" alt="曇り" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/02_n_past.gif">
p class="past">曇り
/p>
/td>
td>
img width="33" height="30" alt="曇り" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/02_past.gif">
p class="past">曇り
/p>
/td>
td>
img width="33" height="30" alt="曇り" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/02.gif">
p>曇り
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01_n.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01_n.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01_n.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01_n.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="曇り" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/02.gif">
p>曇り
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01_n.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01_n.gif">
p>晴れ
/p>
/td>
td>
img width="33" height="30" alt="晴れ" src="http://az416740.vo.msecnd.net/images/icon/weatherPointIcon/01_n.gif">
p>晴れ
/p>
/td>
/tr>
tr class="flashTempGraph">
th abbr="気温(℃)" rowspan="2">気温(℃)
/th>
td colspan="16">
img src="http://az416740.vo.msecnd.net/static-images/forecast_point/point_graph/point_graph_42251.gif?20140726080317" width="815" height="141">
/td>
/tr>
tr class="temperature">
td>
span class="past">26.9
/span>
/td>
td>
span class="past">26.4
/span>
/td>
td>
span>27.8
/span>
/td>
td>
span>34.2
/span>
/td>
td>
span>36.3
/span>
/td>
td>
span>33.4
/span>
/td>
td>
span>30.4
/span>
/td>
td>
span>28.3
/span>
/td>
td>
span>26.9
/span>
/td>
td>
span>26.1
/span>
/td>
td>
span>30.2
/span>
/td>
td>
span>35.0
/span>
/td>
td>
span>34.6
/span>
/td>
td>
span>31.8
/span>
/td>
td>
span>28.8
/span>
/td>
td>
span>26.4
/span>
/td>
/tr>
tr class="humidity">
th abbr="湿度(%)">湿度(%)
/th>
td>
span class="past">96
/span>
/td>
td>
span class="past">96
/span>
/td>
td>
span>87
/span>
/td>
td>
span>62
/span>
/td>
td>
span>62
/span>
/td>
td>
span>74
/span>
/td>
td>
span>90
/span>
/td>
td>
span>94
/span>
/td>
td>
span>92
/span>
/td>
td>
span>96
/span>
/td>
td>
span>72
/span>
/td>
td>
span>50
/span>
/td>
td>
span>48
/span>
/td>
td>
span>60
/span>
/td>
td>
span>64
/span>
/td>
td>
span>74
/span>
/td>
/tr>
tr class="precipGraph">
th abbr="降水量(mm/h)" rowspan="2">降水量(mm/h)
/th>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01_past.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01_past.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/precipitation/01.gif" alt="0" width="48" height="41">
/td>
/tr>
tr class="precipitation">
td>
span class="past">0
/span>
/td>
td>
span class="past">0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
td>
span>0
/span>
/td>
/tr>
tr class="windBlow">
th abbr="風向">風向
/th>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_14_past.gif" alt="北西" width="30" height="30">
p class="past">北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_14_past.gif" alt="北西" width="30" height="30">
p class="past">北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_11.gif" alt="西南西" width="30" height="30">
p>西南西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/3_05.gif" alt="東南東" width="30" height="30">
p>東南東
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/2_05.gif" alt="東南東" width="30" height="30">
p>東南東
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_05.gif" alt="東南東" width="30" height="30">
p>東南東
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_02.gif" alt="北東" width="30" height="30">
p>北東
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_14.gif" alt="北西" width="30" height="30">
p>北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_14.gif" alt="北西" width="30" height="30">
p>北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_14.gif" alt="北西" width="30" height="30">
p>北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_14.gif" alt="北西" width="30" height="30">
p>北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_15.gif" alt="北北西" width="30" height="30">
p>北北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/2_15.gif" alt="北北西" width="30" height="30">
p>北北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/2_15.gif" alt="北北西" width="30" height="30">
p>北北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/2_15.gif" alt="北北西" width="30" height="30">
p>北北西
/p>
/td>
td>
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/2_14.gif" alt="北西" width="30" height="30">
p>北西
/p>
/td>
/tr>
tr class="windSpeed">
th abbr="風速(m/s)">風速(m/s)
/th>
td>
span class="past">2
/span>
/td>
td>
span class="past">2
/span>
/td>
td>
span>1
/span>
/td>
td>
span>5
/span>
/td>
td>
span>4
/span>
/td>
td>
span>2
/span>
/td>
td>
span>1
/span>
/td>
td>
span>2
/span>
/td>
td>
span>2
/span>
/td>
td>
span>2
/span>
/td>
td>
span>1
/span>
/td>
td>
span>2
/span>
/td>
td>
span>4
/span>
/td>
td>
span>4
/span>
/td>
td>
span>3
/span>
/td>
td>
span>4
/span>
/td>
/tr>
/tbody>
/table>
/div>
!-- /.contentsBox -->
script>$(function(){    $('#help_forecast_point_1').hover(      function() {        $('#help_forecast_point_text_1').toggle();      },      function() {        $('#help_forecast_point_text_1').toggle();      }    );    $('#help_forecast_point_1').bind('touchstart', function() {        $('#help_forecast_point_text_1').toggle();    });});
/script>
!-- /point_table.inc 42251 -->
script type="text/javascript">$('#pinpoint_weather_name').html(__point_name + 'の天気');
/script>

div id="bd-main">
!--  #bd-main  -->
script type="text/javascript">
  if(!__b || !__b[0]) {
    document.write('
div class="contentsBox">
div class="wrap free_login_button clearfix">
p class="login_forecast_point_bt left-float">
a href="https://cms.tenki.jp/cms/member/login/?.done=http://www.tenki.jp/forecast/3/13/4210/10201.html" class="clearfix">無料でログインする
/a>
/p>
div class="login_forecast_text">
span class="red">無料ログインで、1時間毎のピンポイント天気をご利用いただけます。
/span>
a href="/docs/renewal_2014">詳細はこちらをご覧ください。
/a>
/div>
/div>
/div>');
  }
/script>
div class="contentsBox">
div class="wrap free_login_button clearfix">
p class="login_forecast_point_bt left-float">
a href="https://cms.tenki.jp/cms/member/login/?.done=http://www.tenki.jp/forecast/3/13/4210/10201.html" class="clearfix">無料でログインする
/a>
/p>
div class="login_forecast_text">
span class="red">無料ログインで、1時間毎のピンポイント天気をご利用いただけます。
/span>
a href="/docs/renewal_2014">詳細はこちらをご覧ください。
/a>
/div>
/div>
/div>
!-- point/table_42251_status.inc 42251 ## generate at 2014-07-26 08:03:17 -->
!-- jwa_p130_id:42251 today:2014-07-26 tomorrow:2014-07-27 announce_datetime:2014-07-26 07:00:00 generate at 2014-07-26 08:03:17 -->
!-- /point/table_42251_status.inc 42251 ## generate at 2014-07-26 08:03:17 -->
!-- heatstroke/weather_panel_city_4210_component.inc map_city_id:58 jwa_forecast_id:4210 name:南部 name2:前橋 map_pref_id:13 map_pref_fullname:群馬県 ## generate at 2014-07-26 08:10:33 -->
!-- 群馬県 南部(前橋)の熱中症情報 2014年07月26日06:00発表 -->
!-- heatstroke weather panel 2014/07/01 -->
div class="contentsBox">
  
div class="wrap">
    
noscript>
&lt;a target='_blank' href='http://ds.advg.jp/adpds_deliver/p/r?adpds_site=tenkijp&amp;adpds_frame=waku_172285'&gt;
&lt;img src='http://ds.advg.jp/adpds_deliver/p/img?adpds_site=tenkijp&amp;adpds_frame=waku_172285' border=0&gt;&lt;/a&gt;
/noscript>
table width="100%" border="0" cellspacing="0" cellpadding="0">
      
tbody>
tr>
         
td style="vertical-align:top:width:160px">
a href="/heatstroke/3/13/4210.html">
img src="http://az416740.vo.msecnd.net/images/contents/heatstroke/guide05.jpg" width="160" height="100" alt="群馬県 南部(前橋)2014年07月26日の熱中症情報 危険 31.0℃以上" title="群馬県 南部(前橋)2014年07月26日の熱中症情報 危険 31.0℃以上">
/a>
/td>
         
!-- from ad server -->
script language="javascript" src="http://ds.advg.jp/adpds_deliver/js/pjs.js">
/script>
script language="javascript">adpds_js('http://ds.advg.jp/adpds_deliver', 'adpds_site=tenkijp&adpds_frame=waku_172285');
/script>
script language="javascript" src="http://ds.advg.jp/adpds_deliver/p/js?adpds_site=tenkijp&amp;adpds_frame=waku_172285&amp;adpds_ref=&amp;adpds_flash=0&amp;adpds_nocache=140633020711648725000">
/script>
td style="vertical-align:top;padding-left:10px;padding-right:10px;">  
a href="http://ds.advg.jp/adpds_deliver/p/r?adpds_sid=1193&amp;adpds_fid=172285&amp;adpds_cpn=144924&amp;adpds_bid=289709&amp;adpds_cid=241981&amp;adpds_nocache=140633020504353176898&amp;adpds_lid=1" class="bold" target="_blank">『熱中症ゼロへ』公式キャンディ『塩熱飴』
/a>
br> 『熱中症ゼロへ』プロジェクト公式キャンディ『塩熱飴』！売れ筋おすすめ塩飴。夏場の仕事やスポーツなどの熱中症対策や室内熱中症対策にも、汗をかいた身体に塩熱飴で素早く塩分・電解質補給！
/td>
td style="vertical-align:top;width:80px">
a href="http://ds.advg.jp/adpds_deliver/p/r?adpds_sid=1193&amp;adpds_fid=172285&amp;adpds_cpn=144924&amp;adpds_bid=289709&amp;adpds_cid=241981&amp;adpds_nocache=140633020504353176898&amp;adpds_lid=1" target="_blank">
img src="http://az416740.vo.msecnd.net/images/contents/heatstroke/140530_contents.jpg" width="80" height="100" alt="『熱中症ゼロへ』公式キャンディ『塩熱飴』">
/a>
/td>
        
!-- /from ad server -->
      
/tr>
    
/tbody>
/table>
  
/div>
!-- /.wrap -->
/div>
!-- /.contentsBox -->
!-- /heatstroke weather panel 2014/07/01 -->
!-- /heatstroke/weather_panel_city_4210_component.inc map_city_id:58 jwa_forecast_id:4210 name:南部 name2:前橋 map_pref_id:13 map_pref_fullname:群馬県 ## generate at 2014-07-26 08:10:33 -->
!-- week.inc map_city_id:58 ## generate at 2014-07-26 08:00:12 -->
style>
#help_weeklyReliability_text {
    width: 130px;
    padding: 5px;
    background-color: #FFFFFF;
    border: 1px solid #888888;
    position: absolute;
    left: 32px;
    z-index: 1000;
    font-weight: normal;
    font-size: 85%;
    text-align: left;
    display: none;
}
/style>
div class="contentsBox">

div class="titleBorder">
div class="titleBgLong">
h2>10日間天気予報
/h2>
div class="weekCityName">- 南部(前橋)
/div>
div class="dateRight" id="week_announce_datetime">2014年07月25日17:00発表
/div>
/div>
/div>

table id="cityWeeklyWeatherV2">

tbody>
tr>
th class="citydate">日付
/th>
td class="cityday">07月28日
br>
(
span>月
/span>)
/td>
td class="cityday">07月29日
br>
(
span>火
/span>)
/td>
td class="cityday">07月30日
br>
(
span>水
/span>)
/td>
td class="cityday">07月31日
br>
(
span>木
/span>)
/td>
td class="cityday">08月01日
br>
(
span>金
/span>)
/td>
td class="cityday">08月02日
br>
(
span class="saturday">土
/span>)
/td>
td class="cityday">08月03日
br>
(
span class="sunday">日
/span>)
/td>
td class="cityday">08月04日
br>
(
span>月
/span>)
/td>
/tr>

tr>
th class="shipsInfo">天気
/th>
td class="amedasIcon">
img src="http://az416740.vo.msecnd.net/images/icon/weatherIcon/09.gif" alt="曇時々晴" title="曇時々晴" width="47" height="30">
p>曇時々晴
/p>
/td>
td class="amedasIcon">
img src="http://az416740.vo.msecnd.net/images/icon/weatherIcon/02.gif" alt="晴時々曇" title="晴時々曇" width="47" height="30">
p>晴時々曇
/p>
/td>
td class="amedasIcon">
img src="http://az416740.vo.msecnd.net/images/icon/weatherIcon/09.gif" alt="曇時々晴" title="曇時々晴" width="47" height="30">
p>曇時々晴
/p>
/td>
td class="amedasIcon">
img src="http://az416740.vo.msecnd.net/images/icon/weatherIcon/09.gif" alt="曇時々晴" title="曇時々晴" width="47" height="30">
p>曇時々晴
/p>
/td>
td class="amedasIcon">
img src="http://az416740.vo.msecnd.net/images/icon/weatherIcon/10.gif" alt="曇一時雨" title="曇一時雨" width="47" height="30">
p>曇一時雨
/p>
/td>
td class="amedasIcon">
img src="http://az416740.vo.msecnd.net/images/icon/weatherIcon/03.gif" alt="晴一時雨" title="晴一時雨" width="47" height="30">
p>晴一時雨
/p>
/td>
td class="amedasIcon">
img src="http://az416740.vo.msecnd.net/images/icon/weatherIcon/03.gif" alt="晴一時雨" title="晴一時雨" width="47" height="30">
p>晴一時雨
/p>
/td>
td class="amedasIcon">
span class="grayOut">---
/span>
p>
span class="grayOut">---
/span>
/p>
/td>
/tr>

tr>
th class="shipsInfo">気温
br>(℃)
/th>
td>
p class="weeklyHighTemp xlarge-font-size">31
/p>
p class="weeklyLowTemp xlarge-font-size">24
/p>
/td>
td>
p class="weeklyHighTemp xlarge-font-size">31
/p>
p class="weeklyLowTemp xlarge-font-size">22
/p>
/td>
td>
p class="weeklyHighTemp xlarge-font-size">31
/p>
p class="weeklyLowTemp xlarge-font-size">22
/p>
/td>
td>
p class="weeklyHighTemp xlarge-font-size">30
/p>
p class="weeklyLowTemp xlarge-font-size">22
/p>
/td>
td>
p class="weeklyHighTemp xlarge-font-size">29
/p>
p class="weeklyLowTemp xlarge-font-size">22
/p>
/td>
td>
p class="weeklyHighTemp xlarge-font-size">34
/p>
p class="weeklyLowTemp xlarge-font-size">22
/p>
/td>
td>
p class="weeklyHighTemp xlarge-font-size">32
/p>
p class="weeklyLowTemp xlarge-font-size">21
/p>
/td>
td>
p class="weeklyHighTemp xlarge-font-size">
span class="grayOut">---
/span>
/p>
p class="weeklyLowTemp xlarge-font-size">
span class="grayOut">---
/span>
/p>
/td>
/tr>

tr>
th class="shipsInfo">降水
br>確率
/th>
td>
p class="weeklyPrecip xlarge-font-size">40%
/p>
/td>
td>
p class="weeklyPrecip xlarge-font-size">30%
/p>
/td>
td>
p class="weeklyPrecip xlarge-font-size">30%
/p>
/td>
td>
p class="weeklyPrecip xlarge-font-size">30%
/p>
/td>
td>
p class="weeklyPrecip xlarge-font-size">60%
/p>
/td>
td>
p class="weeklyPrecip xlarge-font-size">40%
/p>
/td>
td>
p class="weeklyPrecip xlarge-font-size">40%
/p>
/td>
td>
span class="grayOut">---
/span>
/td>
/tr>

tr>
th class="shipsInfo">信頼度
br>
span id="help_weeklyReliability">
img src="http://az416740.vo.msecnd.net/images/contents/heatstroke/icon_help.gif" width="15" height="14" alt="" title="" style="padding-top:2px;">
/span>
p id="help_weeklyReliability_text">※信頼度凡例　
br>　A:確度が高い予報
br>　B:確度がやや高い予報
br>　C:確度がやや低い予報
/p>
/th>
td class="reliability_c">C
/td>
td class="reliability_c">C
/td>
td class="reliability_c">C
/td>
td class="reliability_c">C
/td>
td class="reliability_c">C
/td>
td class="reliability_">
span class="grayOut">---
/span>
/td>
td class="reliability_">
span class="grayOut">---
/span>
/td>
td class="reliability_">
span class="grayOut">---
/span>
/td>
/tr>

/tbody>
/table>
!-- /#cityWeeklyWeather -->

!--
div class="weeklyReliabilitynotice">
信頼度凡例　
span class="weeklyReliability reliability_a">A
/span>:確度が高い予報　
span class="weeklyReliability reliability_b">B
/span>:確度がやや高い予報　
span class="weeklyReliability reliability_c">C
/span>:確度がやや低い予報
/div>-->

div class="notice">
!-- ※週間天気の気温は最寄の観測地点をもとにしているため、一部実際の地域の気温と異なる場合があります。
br /> -->
/div>

/div>
!-- /.contentsBox -->

script>
$(function(){
    $('#help_weeklyReliability').hover(
      function() {
        $('#help_weeklyReliability_text').toggle();
      },
      function() {
        $('#help_weeklyReliability_text').toggle();
      }
    );
    $('#help_weeklyReliability').bind('touchstart', function() {
        $('#help_weeklyReliability_text').toggle();
    });
});
/script>
!-- /week.inc map_city_id:58 -->
!-- long/preview_area_10300.inc jma_code:10300 ## generate at 2014-07-26 08:15:05 -->

div class="contentsBox">

  
div class="titleBorder">
    
div class="titleBgLong">
      
h2>1ヶ月予報
/h2>
      
div class="weekCityName">- 関東甲信地方
/div>
      
div class="dateRight" id="forecat_long_announce_datetime">2014年07月24日14:30発表
/div>
    
/div>
  
/div>
  
  
div class="wrap" style="padding-bottom:0;">
    
h4 class="forecast_long_comment_title">予想される向こう1ヶ月の天候(2014年07月26日～)
/h4>
div class="forecast_long_comment">平年に比べ晴れの日が多いでしょう。
/div>
    
    
    
ul class="forecast_long_graph_index">
      
li class="forecast_long_graph_index_low">
span>平年より低い
/span>
/li>
      
li class="forecast_long_graph_index_same">
span>平年並
/span>
/li>
      
li class="forecast_long_graph_index_high">
span>平年より高い
/span>
/li>
    
/ul>
    
    
h5 class="forecast_long_graph_table_title">気温
/h5>
    
table class="forecast_long_graph_table">
    
    
tbody>
tr>
      
th>関東甲信地方
/th>
      
td>
        
ul class="forecast_long_graph_table_detail">
          
li class="forecast_long_graph_table_detail_20 lowData">20%
/li>
          
li class="forecast_long_graph_table_detail_30 middleData">30%
/li>
          
li class="forecast_long_graph_table_detail_50 highData">50%
/li>
        
/ul>
      
/td>
    
/tr>
    
    
/tbody>
/table>
    
    
h5 class="forecast_long_graph_table_title">降水量
/h5>
    
table class="forecast_long_graph_table">
    
    
tbody>
tr>
      
th>関東甲信地方
/th>
      
td>
        
ul class="forecast_long_graph_table_detail">
          
li class="forecast_long_graph_table_detail_30 lowData">30%
/li>
          
li class="forecast_long_graph_table_detail_40 middleData">40%
/li>
          
li class="forecast_long_graph_table_detail_30 highData">30%
/li>
        
/ul>
      
/td>
    
/tr>
    
    
/tbody>
/table>
    
    
h5 class="forecast_long_graph_table_title">日照時間
/h5>
    
table class="forecast_long_graph_table">
    
    
tbody>
tr>
      
th>関東甲信地方
/th>
      
td>
        
ul class="forecast_long_graph_table_detail">
          
li class="forecast_long_graph_table_detail_20 lowData">20%
/li>
          
li class="forecast_long_graph_table_detail_40 middleData">40%
/li>
          
li class="forecast_long_graph_table_detail_40 highData">40%
/li>
        
/ul>
      
/td>
    
/tr>
    
    
/tbody>
/table>
    
    
    
table class="forecast_long_graph_table">
    
    
/table>
    


  
/div>
!-- /.wrap -->

  
div class="more_link_right_wrap clear right-align">
    
a href="http://www.tenki.jp/long/10300.html" class="more_link_right bold">詳しく見る
/a>
  
/div>
/div>
!-- /.contentsBox -->

!-- /long/preview_area_10300.inc jma_code:10300 ## generate at 2014-07-26 08:15:05 -->

div class="contentsBox" id="city_point_entries">
  
div class="titleBorder">
    
div class="titleBgLong">
      
h2>ピンポイント天気
/h2>
    
/div>
  
/div>
  
div class="wrap">
    
div id="weatherWaveBox" class="clearfix">
    
ul class="clearfix city_point_list">
      
li class="selected">
        前橋市
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10202.html">高崎市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10203.html">桐生市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10204.html">伊勢崎市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10205.html">太田市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10207.html">館林市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10208.html">渋川市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10209.html">藤岡市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10210.html">富岡市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10211.html">安中市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10212.html">みどり市
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10344.html">榛東村
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10345.html">吉岡町
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10366.html">上野村
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10367.html">神流町
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10382.html">下仁田町
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10383.html">南牧村
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10384.html">甘楽町
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10464.html">玉村町
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10521.html">板倉町
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10522.html">明和町
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10523.html">千代田町
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10524.html">大泉町
/a>
      
/li>
    
      
li>
        
a href="/forecast/3/13/4210/10525.html">邑楽町
/a>
      
/li>
        
/ul>
    
/div>
  
/div>
!-- /.wrap -->

/div>
!-- /.contentsBox -->

!-- mainpage_ppc forecast -->
div class="contentsBox google_mainpage_ppc_bottom">
div class="left-float">
script type="text/javascript">
!--
google_ad_client = "ca-pub-0500318860241778";
/* footer_forecast */
google_ad_slot = "8805748387";
google_ad_width = 300;
google_ad_height = 250;
//-->
/script>
script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
/script>
ins style="display:inline-table;border:none;height:250px;margin:0;padding:0;position:relative;visibility:visible;width:300px;background-color:transparent">
ins id="aswift_1_anchor" style="display:block;border:none;height:250px;margin:0;padding:0;position:relative;visibility:visible;width:300px;background-color:transparent">
iframe width="300" height="250" frameborder="0" marginwidth="0" marginheight="0" vspace="0" hspace="0" allowtransparency="true" scrolling="no" allowfullscreen="true" onload="var i=this.id,s=window.google_iframe_oncopy,H=s&amp;&amp;s.handlers,h=H&amp;&amp;H[i],w=this.contentWindow,d;try{d=w.document}catch(e){}if(h&amp;&amp;d&amp;&amp;(!d.body||!d.body.firstChild)){if(h.call){setTimeout(h,0)}else if(h.match){try{h=s.upd(h,i)}catch(e){}w.location.replace(h)}}" id="aswift_1" name="aswift_1" style="left:0;position:absolute;top:0;">
/iframe>
/ins>
/ins>
/div>
!-- /.left-float -->
div class="right-float">
!--/* adfunnel.microad.jp Javascript Tag v */-->

script type="text/javascript">
!--//
![CDATA[
   document.MAX_ct0 ='INSERT_CLICKURL_HERE';

if (location.protocol=='https:') {
} else {
   var m3_u = 'http://adf.send.microad.jp/ajs.php';
   var m3_r = Math.floor(Math.random()*99999999999);
   if (!document.MAX_used) document.MAX_used = ',';
   document.write ("
scr"+"ipt type='text/javascript' src='"+m3_u);
   document.write ("?zoneid=14069");
   document.write ('&amp;snr=1&amp;cb=' + m3_r);
   if (document.MAX_used != ',') document.write ("&amp;exclude=" + document.MAX_used);
   document.write (document.charset ? '&amp;charset='+document.charset : (document.characterSet ? '&amp;charset='+document.characterSet : ''));
   document.write ("&amp;loc=" + encodeURIComponent(window.location));
   if (document.referrer) document.write ("&amp;referer=" + encodeURIComponent(document.referrer));
   if (document.context) document.write ("&context=" + encodeURIComponent(document.context));
   if ((typeof(document.MAX_ct0) != 'undefined') && (document.MAX_ct0.substring(0,4) == 'http')) {
       document.write ("&amp;ct0=" + encodeURIComponent(document.MAX_ct0));
   }
   if (document.mmm_fo) document.write ("&amp;mmm_fo=1");
   document.write ("'>
\/scr"+"ipt>");
}
//]]>-->
/script>
script type="text/javascript" src="http://adf.send.microad.jp/ajs.php?zoneid=14069&amp;snr=1&amp;cb=40805345563&amp;charset=UTF-8&amp;loc=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html">
/script>
!--/* OpenX IFrame tag */-->
iframe id="529c32fa5bf9c" name="529c32fa5bf9c" src="http://servedby.openxmarket.jp/w/1.0/afr?auid=444674&amp;cb=INSERT_RANDOM_NUMBER_HERE" frameborder="0" framespacing="0" scrolling="no" width="300" height="250">&lt;a href="http://adf.send.microad.jp/ck.php?oaparams=2__bannerid=54015__snr=1__zoneid=14069__OXLCA=1__cb=180b607179__t=1406330205.4775__oadest=http%3A%2F%2Fservedby.openxmarket.jp%2Fw%2F1.0%2Frc%3Fcs%3D529c32fa5bf9c%26cb%3DINSERT_RANDOM_NUMBER_HERE" target="_blank"&gt;&lt;img src="http://servedby.openxmarket.jp/w/1.0/ai?auid=444674&amp;cs=529c32fa5bf9c&amp;cb=INSERT_RANDOM_NUMBER_HERE" border="0" alt=""&gt;&lt;/a&gt;
/iframe>
div id="beacon_180b607179" style="position: absolute; left: 0px; top: 0px; visibility: hidden;">
img src="http://adf.send.microad.jp/lg.php?bannerid=54015&amp;campaignid=3434&amp;zoneid=14069&amp;cb=180b607179&amp;t=1406330205.4775&amp;snr=1" width="0" height="0" alt="" style="width: 0px; height: 0px;">
/div>
noscript>&lt;a href='http://adf.send.microad.jp/ck.php?n=ac08072f&amp;amp;cb=INSERT_RANDOM_NUMBER_HERE' target='_blank'&gt;&lt;img src='http://adf.send.microad.jp/avw.php?zoneid=14069&amp;amp;cb=INSERT_RANDOM_NUMBER_HERE&amp;amp;n=ac08072f&amp;amp;ct0=INSERT_CLICKURL_HERE&amp;amp;snr=1' border='0' alt='' /&gt;&lt;/a&gt;
/noscript>
/div>
!-- /.right-float -->
/div>
!-- /mainpage_ppc forecast -->


/div>
!-- /#bd-main -->

div id="bd-sub">


!-- for 天気予報・ピンポイント天気 PD1 -->
div id="ad-large-lectangle" class="ad-large-lectangle">
!-- 2013/08/30 for PD1 群馬 -->
!-- 1st_PD_point_gunma -->
div id="div-gpt-ad-1377771504626-0">
script type="text/javascript">
googletag.display('div-gpt-ad-1377771504626-0');
/script>
script type="text/javascript" src="http://pubads.g.doubleclick.net/gampad/ads?gdfp_req=1&amp;correlator=415564046532608&amp;output=json_html&amp;callback=googletag.impl.pubads.setAdContentsBySlotForSync&amp;impl=ss&amp;json_a=1&amp;sfv=1-0-0&amp;iu_parts=11384922%2C1st_PD_point_gunma%2C2nd_PD_forecast&amp;enc_prev_ius=%2F0%2F1%2C%2F0%2F2&amp;prev_iu_szs=300x250%7C300x600%2C300x250&amp;cookie_enabled=1&amp;lmt=1406297807&amp;dt=1406330207585&amp;cc=99&amp;frm=20&amp;biw=400&amp;bih=300&amp;oid=3&amp;adks=4269505005%2C2931986399&amp;gut=v2&amp;ifi=3&amp;u_tz=540&amp;u_his=1&amp;u_h=768&amp;u_w=1024&amp;u_ah=768&amp;u_aw=1024&amp;u_cd=32&amp;u_sd=1&amp;flash=0&amp;url=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html&amp;vrg=45&amp;vrp=45&amp;ga_vid=332378148.1406330205&amp;ga_sid=1406330205&amp;ga_hid=1199068482&amp;ga_fc=true">
/script>
div id="div-gpt-ad-1377771504626-0_ad_container">
ins style="width: 300px; height: 250px; display: inline-table; position: relative; border-top-width: 0px; border-right-width: 0px; border-bottom-width: 0px; border-left-width: 0px; border-style: initial; border-color: initial; vertical-align: bottom; ">
ins style="width: 300px; height: 250px; display: block; position: relative; border-top-width: 0px; border-right-width: 0px; border-bottom-width: 0px; border-left-width: 0px; border-style: initial; border-color: initial; ">
iframe id="google_ads_iframe_/11384922/1st_PD_point_gunma_0" name="google_ads_iframe_/11384922/1st_PD_point_gunma_0" width="300" height="250" scrolling="no" marginwidth="0" marginheight="0" frameborder="0" style="border-top-width: 0px; border-right-width: 0px; border-bottom-width: 0px; border-left-width: 0px; border-style: initial; border-color: initial; position: absolute; top: 0px; left: 0px; ">
/iframe>
/ins>
/ins>
/div>
script>googletag.impl.pubads.createDomIframe("div-gpt-ad-1377771504626-0_ad_container" ,"/11384922/1st_PD_point_gunma_0",false,undefined);
/script>
/div>
!-- /2013/08/30 for PD1 群馬 -->
/div>
!-- for 天気予報・ピンポイント天気 PD1 -->


!-- tsunami/tsunami_top_notice.inc ## generate at 2014-07-26 08:07:43 -->
!-- /tsunami/tsunami_top_notice.inc ## generate at 2014-07-26 08:07:43 -->
!-- earthquake/earthquake_top_notice.inc ## generate at 2014-07-26 08:16:03 -->
!-- /earthquake/earthquake_top_notice.inc ## generate at 2014-07-26 08:16:03 -->
!-- typhoon/typhoon_top_notice.inc ## generate at 2014-07-26 08:03:06 -->
!-- /typhoon/typhoon_top_notice.inc ## generate at 2014-07-26 08:03:06 -->

!-- weather_guide/weather_guide_pref_13_component.inc ## id:13 name:群馬県 ## generate at 2014-02-17 17:22:16 -->
!-- weather_guide -->
script type="text/javascript">
!--
var weather_guide_tabs_cache = {'satellite': {
    'link': 'http://www.tenki.jp/satellite/japan_east/',
    'url' : 'http://az416740.vo.msecnd.net/static-images/satellite/recent_entry/japan_east/small.jpg?20140217172200'
},

'chart': {
    'link': 'http://www.tenki.jp/guide/chart/',
    'url': 'http://az416740.vo.msecnd.net/static-images/chart/recent_entry/small.jpg?20140217172200'
},
'radar': {
    'link': 'http://www.tenki.jp/rader/3/13/',
    'url': 'http://az416740.vo.msecnd.net/static-images/rader/recent_entry/pref_13/small.jpg?20140217172200'
},
'amedas': {
    'link': 'http://www.tenki.jp/amedas/3/13/',
    'url': 'http://az416740.vo.msecnd.net/static-images/amedas/map/recent_entry/pref_13_temp_small.jpg?20140217172200'
},
'pm25': {
    'link': 'http://guide.tenki.jp/guide/particulate_matter/japan_east.html',
    'url' : 'http://az416740.vo.msecnd.net/static-images/particulate_matter/recent_entry/recent_entry_japan_east_small.jpg'
}

};
-->
/script>

div class="contentsBox">
  
div class="titleBorder">
    
div class="titleBgLong">
      
h3>天気ガイド(群馬県)
/h3>
    
/div>
  
/div>
  
!-- .fourTabs -->
  
div id="weather_guide_tab" class="fiveTabs">
    
ul>
      
li id="weather_guide_tab_link_satellite" class="firstChild">
a href="http://www.tenki.jp/satellite/japan_east/">
span>衛星
/span>
/a>
/li>
      
li id="weather_guide_tab_link_chart">
a href="http://www.tenki.jp/guide/chart/">
span>天気図
/span>
/a>
/li>
      
li id="weather_guide_tab_link_radar" class="activeTab">
a href="http://www.tenki.jp/rader/3/13/">
span>雨雲
/span>
/a>
/li>
      
li id="weather_guide_tab_link_amedas" class="">
a href="http://www.tenki.jp/amedas/3/13/">
span>アメダス
/span>
/a>
/li>
      
li id="weather_guide_tab_link_pm25" class="lastChild">
a href="http://guide.tenki.jp/guide/particulate_matter/japan_east.html">
span>PM2.5
/span>
/a>
/li>
    
/ul>
    
div id="weather_guide_tab_body" class="center-align" style="padding:9px">
a href="http://www.tenki.jp/rader/3/13/">
img src="http://az416740.vo.msecnd.net/static-images/rader/recent_entry/pref_13/small.jpg?20140217172200" alt="雨雲の動き" title="雨雲の動き" width="276" height="207">
/a>    
/div>
  
/div>
  
!-- /.fourTabs -->
/div>
!-- /.contentsBox -->

script type="text/javascript">
!--
$('#weather_guide_tab > ul > li').click(function(){
  var $$ = $(this);
  $('#weather_guide_tab > ul > li').removeClass('activeTab');
  $$.addClass('activeTab');
  var _key  = this.id.split('_').pop();
  var _url  = weather_guide_tabs_cache[_key]['url'];
  var _link = weather_guide_tabs_cache[_key]['link'];
  var _width = _key == 'chart' ? 277 : 276;
  var _html  = '
a href="' + _link + '">
img src="' + _url + '" width="' + _width + '" height="207" />
/a>';
  $('#weather_guide_tab_body').html(_html);
  return false;
});
-->
/script>
!-- /weather_guide -->
!-- /weather_guide/weather_guide_pref_13_component.inc ## id:13 name:群馬県 -->


div class="contentsBox sidemenu_thumbnail_box">
  
div style="margin-bottom:20px">
    
h4 class="sub_title bold">注目の情報
/h4>
    
!-- forecast/sidemenu_twitter_city_4210.inc ## generate at 2014-07-23 12:07:41 -->
    
table cellspacing="0" style="width:290px;border:none;">
      
tbody>
tr>
        
td style="width:50px;vertical-align:top;padding-top:5px;">
a href="https://twitter.com/tenkijp_maebash" target="_blank">
img src="http://az416740.vo.msecnd.net/images/contents/common/banner/tenkijp_twitter_50_50.png" alt="twitter" border="0" width="50" height="50">
/a>
/td>
        
td style="width:230px;padding:2px 0 5px 10px;text-align:left;">
a href="https://twitter.com/tenkijp_maebash" target="_blank">
span class="bold">前橋の天気予報を配信
/span>
br>tenki.jpの公式Twitterをご利用ください。
br>天気、降水確率、最高最低気温を配信中
/a>
/td>
      
/tr>
    
/tbody>
/table>
!-- forecast/sidemenu_twitter_city_4210.inc ## generate at 2014-07-23 12:07:41 -->

    
!-- /注目の情報 -->
  
/div>
!-- /.wrap -->
/div>
!-- /.contentsBox /.sidemenu_thumbnail_box -->

!-- mini showcase 2014/01/09 -->
div style="margin-bottom:10px">
script language="javascript" src="http://ds.advg.jp/adpds_deliver/js/pjs.js">
/script>
script language="javascript">adpds_js('http://ds.advg.jp/adpds_deliver', 'adpds_site=tenkijp&adpds_frame=waku_169568');
/script>
script language="javascript" src="http://ds.advg.jp/adpds_deliver/p/js?adpds_site=tenkijp&amp;adpds_frame=waku_169568&amp;adpds_ref=&amp;adpds_flash=0&amp;adpds_nocache=140633020803936591270">
/script>
noscript>
&lt;a target='_blank' href='http://ds.advg.jp/adpds_deliver/p/r?adpds_site=tenkijp&amp;adpds_frame=waku_169568'&gt;
&lt;img src='http://ds.advg.jp/adpds_deliver/p/img?adpds_site=tenkijp&amp;adpds_frame=waku_169568' border=0&gt;&lt;/a&gt;
/noscript>
/div>
!-- /mini showcase 2014/01/09 -->

!-- mini showcase 2014/07/01 -->
div style="margin-bottom:10px">
script language="javascript" src="http://ds.advg.jp/adpds_deliver/js/pjs.js">
/script>
script language="javascript">adpds_js('http://ds.advg.jp/adpds_deliver', 'adpds_site=tenkijp&adpds_frame=waku_173196');
/script>
script language="javascript" src="http://ds.advg.jp/adpds_deliver/p/js?adpds_site=tenkijp&amp;adpds_frame=waku_173196&amp;adpds_ref=&amp;adpds_flash=0&amp;adpds_nocache=140633020807687246455">
/script>
a href="http://ds.advg.jp/adpds_deliver/p/r?adpds_sid=1193&amp;adpds_fid=173196&amp;adpds_cpn=145404&amp;adpds_bid=293050&amp;adpds_cid=244419&amp;adpds_nocache=140633020601356160056" target="_top">
img src="http://img.adplan-ds.com/D1193/3_300_80.gif" width="300" height="80" border="0" alt="advertisement">
/a>
noscript>
&lt;a target='_blank' href='http://ds.advg.jp/adpds_deliver/p/r?adpds_site=tenkijp&amp;adpds_frame=waku_173196'&gt;
&lt;img src='http://ds.advg.jp/adpds_deliver/p/img?adpds_site=tenkijp&amp;adpds_frame=waku_173196' border=0&gt;&lt;/a&gt;
/noscript>
/div>
!-- /mini showcase 2014/07/01 -->

!-- #large_rectangle_middle -->
div id="large_rectangle_middle" class="ad-large-lectangle">
!-- for 天気予報・ピンポイント天気 PD2 -->
!-- 2013/08/30 for PD2 群馬 -->
!-- 2nd_PD_forecast -->
div id="div-gpt-ad-1377771504626-1" style="width:300px; height:250px;">
script type="text/javascript">
googletag.display('div-gpt-ad-1377771504626-1');
/script>
div id="div-gpt-ad-1377771504626-1_ad_container">
script type="text/javascript">
!--//
![CDATA[
   document.MAX_ct0 ='INSERT_CLICKURL_HERE';

if (location.protocol=='https:') {
} else {
   var m3_u = 'http://adf.send.microad.jp/ajs.php';
   var m3_r = Math.floor(Math.random()*99999999999);
   if (!document.MAX_used) document.MAX_used = ',';
   document.write ("
scr"+"ipt type='text/javascript' src='"+m3_u);
   document.write ("?zoneid=14676&amp;charset=UTF-8");
   document.write ('&amp;snr=1&amp;cb=' + m3_r);
   if (document.MAX_used != ',') document.write ("&amp;exclude=" + document.MAX_used);
   document.write ('&amp;charset=UTF-8');
   document.write ("&amp;loc=" + encodeURIComponent(window.location));
   if (document.referrer) document.write ("&amp;referer=" + encodeURIComponent(document.referrer));
   if (document.context) document.write ("&context=" + encodeURIComponent(document.context));
   if ((typeof(document.MAX_ct0) != 'undefined') && (document.MAX_ct0.substring(0,4) == 'http')) {
       document.write ("&amp;ct0=" + encodeURIComponent(document.MAX_ct0));
   }
   if (document.mmm_fo) document.write ("&amp;mmm_fo=1");
   document.write ("'>
\/scr"+"ipt>");
}
//]]>-->
/script>
script type="text/javascript" src="http://adf.send.microad.jp/ajs.php?zoneid=14676&amp;charset=UTF-8&amp;snr=1&amp;cb=12657440383&amp;charset=UTF-8&amp;loc=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html">
/script>
!--/* OpenX JavaScript tag */-->
!-- /*
* The tag in this template has been generated for use on a
* non-SSL page. If this tag is to be placed on an SSL page, change the
* 'http://servedby.openxmarket.jp/...'
* to
* 'https://servedby.openxmarket.jp/...'
*/ -->
script type="text/javascript">
if (!window.OX_ads) { OX_ads = []; }
OX_ads.push({ "auid" : "479511" });
/script>
script type="text/javascript">
document.write('
scr'+'ipt src="http://servedby.openxmarket.jp/w/1.0/jstag">
\/scr'+'ipt>');
/script>
script src="http://servedby.openxmarket.jp/w/1.0/jstag">
/script>
script type="text/javascript" id="ox_acj_5964754390" src="http://servedby.openxmarket.jp/w/1.0/acj?o=5964754390&amp;callback=OX_5964754390&amp;ju=http%3A//www.tenki.jp/forecast/3/13/4210/10201.html&amp;jr=&amp;auid=479511&amp;tp.rv.data=a&amp;res=1024x768x32&amp;plg=pm&amp;ch=UTF-8&amp;tz=-540&amp;ws=400x300&amp;sd=1">
/script>
iframe src="http://jp-u.openx.net/w/1.0/pd?plm=1&amp;ph=b5df81f9413b9e95ee35f8fd2dbf309ec9d0322f" width="0" height="0" style="display:none;">
/iframe>
!--/* adfunnel.microad.jp Javascript Tag v */-->

script type="text/javascript">
!--//
![CDATA[
   document.MAX_ct0 ='INSERT_CLICKURL_HERE';

if (location.protocol=='https:') {
} else {
   var m3_u = 'http://adf.send.microad.jp/ajs.php';
   var m3_r = Math.floor(Math.random()*99999999999);
   if (!document.MAX_used) document.MAX_used = ',';
   document.write ("
scr"+"ipt type='text/javascript' src='"+m3_u);
   document.write ("?zoneid=14679&amp;charset=UTF-8");
   document.write ('&amp;snr=1&amp;cb=' + m3_r);
   if (document.MAX_used != ',') document.write ("&amp;exclude=" + document.MAX_used);
   document.write ('&amp;charset=UTF-8');
   document.write ("&amp;loc=" + encodeURIComponent(window.location));
   if (document.referrer) document.write ("&amp;referer=" + encodeURIComponent(document.referrer));
   if (document.context) document.write ("&context=" + encodeURIComponent(document.context));
   if ((typeof(document.MAX_ct0) != 'undefined') && (document.MAX_ct0.substring(0,4) == 'http')) {
       document.write ("&amp;ct0=" + encodeURIComponent(document.MAX_ct0));
   }
   if (document.mmm_fo) document.write ("&amp;mmm_fo=1");
   document.write ("'>
\/scr"+"ipt>");
}
//]]>-->
/script>
script type="text/javascript" src="http://adf.send.microad.jp/ajs.php?zoneid=14679&amp;charset=UTF-8&amp;snr=1&amp;cb=40676220040&amp;charset=UTF-8&amp;loc=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html">
/script>
script type="text/javascript" language="JavaScript">
!--
yads_ad_ds = '62067_6966';
//-->
/script>
script type="text/javascript" language="JavaScript" src="http://yads.yahoo.co.jp/js/yads.js">
/script>
script type="text/javascript" language="JavaScript" src="http://i.yimg.jp/images/listing/tool/yads/uadf/yads_vimps_ctrl.js?2014072601">
/script>
span>
/span>
script src="http://yads.yahoo.co.jp/tag?t=j&amp;age=&amp;cu=&amp;debug=&amp;enc=UTF-8&amp;f_path=&amp;gen=&amp;i=&amp;oi_path=http%3A%2F%2Fyads.yahoo.co.jp%2Foi&amp;p_elem=&amp;page=1&amp;ref=&amp;rid=&amp;s=62067_6966&amp;sid=&amp;tag_path=http%3A%2F%2Fyads.yahoo.co.jp%2Ftag&amp;tflg=0&amp;type=&amp;u=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html&amp;w=&amp;noad_cb=&amp;fr_id=yads_9530518-0&amp;fr_support=1&amp;fl_support=0&amp;pv_ts=1406330208498-5417473&amp;tagpos=645x1592&amp;xd_support=1&amp;ssl=0">
/script>
div style="text-align:center;">
iframe src="http://i.yimg.jp/images/listing/tool/yads/yads-iframe.html?t=f&amp;noad_cb=&amp;oi_path=http%3a%2f%2fyads.yahoo.co.jp%2foi&amp;tagpos=645x1592&amp;sid=&amp;cu=&amp;enc=UTF-8&amp;ref=&amp;u=http%3a%2f%2fwww.tenki.jp%2fforecast%2f3%2f13%2f4210%2f10201.html&amp;w=&amp;i=&amp;fr_support=1&amp;fr_id=yads_9530518-0&amp;page=1&amp;rid=&amp;tag_path=http%3a%2f%2fyads.yahoo.co.jp%2ftag&amp;fl_support=0&amp;debug=&amp;tflg=0&amp;p_elem=&amp;pv_ts=1406330208498-5417473&amp;type=&amp;xd_support=1&amp;s=62067_6966-8566" style="border:none; clear:both; display:block; margin:auto; overflow:hidden; " allowtransparency="true" frameborder="0" height="250" id="yads_9530518-0" name="yads_9530518-0" scrolling="no" width="300">
/iframe>
/div>
div id="beacon_2c9b7a031f" style="position: absolute; left: 0px; top: 0px; visibility: hidden;">
img src="http://adf.send.microad.jp/lg.php?bannerid=70469&amp;campaignid=16081&amp;zoneid=14679&amp;cb=2c9b7a031f&amp;t=1406330206.2727&amp;snr=1" width="0" height="0" alt="" style="width: 0px; height: 0px;">
/div>
noscript>&lt;a href='http://adf.send.microad.jp/ck.php?n=aef13c9b&amp;amp;cb=INSERT_RANDOM_NUMBER_HERE' target='_blank'&gt;&lt;img src='http://adf.send.microad.jp/avw.php?zoneid=14679&amp;amp;charset=UTF-8&amp;amp;cb=INSERT_RANDOM_NUMBER_HERE&amp;amp;n=aef13c9b&amp;amp;ct0=INSERT_CLICKURL_HERE&amp;amp;snr=1' border='0' alt='' /&gt;&lt;/a&gt;
/noscript>
div style="position:absolute;left:0px;top:0px;visibility:hidden;">
img src="http://servedby.openxmarket.jp/w/1.0/ri?ts=1fHJpZD0xMzJiYzViZC01YzUwLTQ5YTItYWIxMS00MGNiMTYxMzVhZTV8cnQ9MTQwNjMzMDIwNnxhdWlkPTQ3OTUxMXxhdW09RE1JRC5XRUJ8c2lkPTk2NDM1fHB1Yj02OTM1M3xwYz1KUFl8cmFpZD01YWNkNDJkOC03NDNmLTQwMDYtYjYxOS1iMmNhODg2YTdjM2Z8dXI9MkRoSG5SaHluaA">
/div>
noscript>&lt;iframe id="52319f1bd25c2" name="52319f1bd25c2" src="http://servedby.openxmarket.jp/w/1.0/afr?auid=479511&amp;cb=INSERT_RANDOM_NUMBER_HERE" frameborder="0" scrolling="no" width="300" height="250"&gt;&lt;a href="http://adf.send.microad.jp/ck.php?oaparams=2__bannerid=58856__snr=1__zoneid=14676__OXLCA=1__cb=5280537e18__t=1406330206.0887__oadest=http%3A%2F%2Fservedby.openxmarket.jp%2Fw%2F1.0%2Frc%3Fcs%3D52319f1bd25c2%26cb%3DINSERT_RANDOM_NUMBER_HERE" target="_blank"&gt;&lt;img src="http://servedby.openxmarket.jp/w/1.0/ai?auid=479511&amp;cs=52319f1bd25c2&amp;cb=INSERT_RANDOM_NUMBER_HERE" border="0" alt=""&gt;&lt;/a&gt;&lt;/iframe&gt;
/noscript>
div id="beacon_5280537e18" style="position: absolute; left: 0px; top: 0px; visibility: hidden;">
img src="http://adf.send.microad.jp/lg.php?bannerid=58856&amp;campaignid=3434&amp;zoneid=14676&amp;cb=5280537e18&amp;t=1406330206.0887&amp;snr=1" width="0" height="0" alt="" style="width: 0px; height: 0px;">
/div>
noscript>&lt;a href='http://adf.send.microad.jp/ck.php?n=afba830a&amp;amp;cb=INSERT_RANDOM_NUMBER_HERE' target='_blank'&gt;&lt;img src='http://adf.send.microad.jp/avw.php?zoneid=14676&amp;amp;charset=UTF-8&amp;amp;cb=INSERT_RANDOM_NUMBER_HERE&amp;amp;n=afba830a&amp;amp;ct0=INSERT_CLICKURL_HERE&amp;amp;snr=1' border='0' alt='' /&gt;&lt;/a&gt;
/noscript>
/div>

/div>
!-- /2013/08/30 for PD2 群馬 -->
/div>
!-- /#large_rectangle_middle -->
!-- for 天気予報・ピンポイント天気 PD2 -->


div style="margin-bottom:10px;">
!-- 天気予報都道府県ページ サブカラム下部  2011/10/08～ -->
a href="http://sumai.tenki.jp/tnk_kensaku_mansion_gunma/" target="_blank">
img src="http://az416740.vo.msecnd.net/images/ad/sub_column_bottom/suumo/20111107/14tenki_gunma.gif" width="300" height="80" alt="advertisement">
/a>
!-- /SUUMO 固定リンク 2011/10/08～ -->
/div>
!-- amedas/point_summary/amedas_ten_entries_42251_component.inc name:前橋 amedas_code:42251 ## generate at 2014-07-26 08:14:29 -->
div class="contentsBox">

  
div class="titleBorder">
    
div class="titleBgLong">
      
h4>アメダス10分値(前橋)
/h4>
      
div class="dateRight">26日08:00現在
/div>
    
/div>
  
/div>

  
table border="0" cellspacing="0" cellpadding="0" class="live_point_amedas_ten_summary_entries">
  
tbody>
tr>
    
th>時間
/th>
th>気温
br>(℃)
/th>
th>降水量
br>(mm/h)
/th>
th>日照
br>時間(分)
/th>
th>風向
/th>
th>風速
br>(m/s)
/th>
  
/tr>
  
tr>
    
td class="time_entry">08:00
/td>
    
td class="temp_entry">29.7
/td>
    
td class="precip_entry">0.0
/td>
    
td>60
/td>
    
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_12.gif" width="30" height="30" alt="西" title="西">
/td>
    
td class="wind_speed_entry">1.4
/td>
  
/tr>
    
tr>
    
td class="time_entry">07:50
/td>
    
td class="temp_entry">29.6
/td>
    
td class="precip_entry">0.0
/td>
    
td>60
/td>
    
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_13.gif" width="30" height="30" alt="西北西" title="西北西">
/td>
    
td class="wind_speed_entry">1.3
/td>
  
/tr>
    
tr>
    
td class="time_entry">07:40
/td>
    
td class="temp_entry">29.2
/td>
    
td class="precip_entry">0.0
/td>
    
td>60
/td>
    
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_10.gif" width="30" height="30" alt="南西" title="南西">
/td>
    
td class="wind_speed_entry">0.5
/td>
  
/tr>
    
/tbody>
/table>

  
div class="more_link_right_wrap clear right-align">
    
a href="http://www.tenki.jp/amedas/3/13/42251.html" class="more_link_right bold">もっとみる
/a>
  
/div>

/div>
!-- /.contentsBox -->

!-- /amedas/point_summary/amedas_ten_entries_42251_component.inc name:前橋 amedas_code:42251 ## generate at 2014-07-26 08:14:29 -->
!-- amedas/entries_point_42251_near_entries.inc jma_code:42251 name:前橋 2014年07月26日 08時00分観測 ## generate at 2014-07-26 08:11:25 -->
div class="contentsBox">
  
div class="titleBorder">
      
div class="titleBgLong">
          
h3>前橋の周辺のアメダス
/h3>
          
div class="dateRight">26日08:00観測
/div>
      
/div>
  
/div>
  
div>
    
table border="0" cellspacing="0" cellpadding="0" class="amedas_point_amedas_ten_summary_entries">
    
tbody>
tr>
      
th>&nbsp;
/th>
th>気温
br>(℃)
/th>
th>降水量
br>(mm/h)
/th>
th>風向
/th>
th>風速
br>(m/s)
/th>
th>日照
br>時間(分)
/th>
    
/tr>    
tr>
      
td class="point_name">
a href="/amedas/3/13/42341.html">藤岡
/a>
/td>
      
td class="temp_entry">
span class="grey">---
/span>
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/00.gif" width="30" height="30" alt="" title="">
/td>
      
td class="wind_speed_entry">
span class="grey">---
/span>
/td>
      
td class="sunshine_entry">
span class="grey">---
/span>
/td>
    
/tr>
        
tr>
      
td class="point_name">
a href="/amedas/3/13/42302.html">伊勢崎
/a>
/td>
      
td class="temp_entry">29.3
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_16.gif" width="30" height="30" alt="北" title="北">
/td>
      
td class="wind_speed_entry">0.6
/td>
      
td class="sunshine_entry">60
/td>
    
/tr>
        
tr>
      
td class="point_name">
a href="/amedas/3/13/42286.html">上里見
/a>
/td>
      
td class="temp_entry">29.1
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_03.gif" width="30" height="30" alt="東北東" title="東北東">
/td>
      
td class="wind_speed_entry">1.4
/td>
      
td class="sunshine_entry">60
/td>
    
/tr>
        
tr>
      
td class="point_name">
a href="/amedas/3/13/42146.html">沼田
/a>
/td>
      
td class="temp_entry">28.0
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_15.gif" width="30" height="30" alt="北北西" title="北北西">
/td>
      
td class="wind_speed_entry">1.0
/td>
      
td class="sunshine_entry">60
/td>
    
/tr>
        
tr>
      
td class="point_name">
a href="/amedas/3/13/42241.html">榛名山
/a>
/td>
      
td class="temp_entry">
span class="grey">---
/span>
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/00.gif" width="30" height="30" alt="" title="">
/td>
      
td class="wind_speed_entry">
span class="grey">---
/span>
/td>
      
td class="sunshine_entry">
span class="grey">---
/span>
/td>
    
/tr>
        
tr>
      
td class="point_name">
a href="/amedas/3/13/42266.html">桐生
/a>
/td>
      
td class="temp_entry">28.7
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_05.gif" width="30" height="30" alt="東南東" title="東南東">
/td>
      
td class="wind_speed_entry">1.4
/td>
      
td class="sunshine_entry">60
/td>
    
/tr>
        
tr>
      
td class="point_name">
a href="/amedas/3/13/42261.html">黒保根
/a>
/td>
      
td class="temp_entry">
span class="grey">---
/span>
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/00.gif" width="30" height="30" alt="" title="">
/td>
      
td class="wind_speed_entry">
span class="grey">---
/span>
/td>
      
td class="sunshine_entry">
span class="grey">---
/span>
/td>
    
/tr>
        
tr>
      
td class="point_name">
a href="/amedas/3/13/42186.html">中之条
/a>
/td>
      
td class="temp_entry">26.6
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_01.gif" width="30" height="30" alt="北北東" title="北北東">
/td>
      
td class="wind_speed_entry">0.7
/td>
      
td class="sunshine_entry">60
/td>
    
/tr>
        
tr>
      
td class="point_name">
a href="/amedas/3/14/43051.html">寄居
/a>
/td>
      
td class="temp_entry">28.8
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_01.gif" width="30" height="30" alt="北北東" title="北北東">
/td>
      
td class="wind_speed_entry">1.1
/td>
      
td class="sunshine_entry">60
/td>
    
/tr>
        
tr>
      
td class="point_name">
a href="/amedas/3/14/43156.html">秩父
/a>
/td>
      
td class="temp_entry">27.7
/td>
      
td class="precip_entry">0.0
/td>
      
td class="wind_direction_entry">
img src="http://az416740.vo.msecnd.net/images/icon/windPointIcon/1_11.gif" width="30" height="30" alt="西南西" title="西南西">
/td>
      
td class="wind_speed_entry">0.4
/td>
      
td class="sunshine_entry">49
/td>
    
/tr>
        
/tbody>
/table>
  
/div>
/div>
!-- /.contentsBox -->
!-- /amedas/entries_point_42251_near_entries.inc jma_code:42251 name:前橋 2014年07月26日 08時00分観測 -->

!-- GMO audience tag 2013/10/09 -->
script>
if(typeof dmids == "undefined"){var dmids = {}};
dmids["a7ab697a26801a71"] = "j.gmodmp.jp";
/script>
script src="http://j.gmodmp.jp/js/d.js" type="text/javascript">
/script>
!-- /GMO audience tag 2013/10/09 -->

!-- deqwas.net category 2012/12/21 -->
div id="deqwas-collection-k">
iframe id="deqwas-k_null" src="http://mark003.deqwas.net/common/Collection.aspx?cid=tenki&amp;oid=forecast&amp;category=%E3%83%88%E3%83%83%E3%83%97%2F%E9%96%A2%E6%9D%B1%E3%83%BB%E7%94%B2%E4%BF%A1%E5%9C%B0%E6%96%B9%2F%E7%BE%A4%E9%A6%AC%E7%9C%8C&amp;oquan=%E7%BE%A4%E9%A6%AC%E7%9C%8C&amp;role=item&amp;l=%E7%BE%A4%E9%A6%AC%E7%9C%8C&amp;essential=nothing&amp;cb=1406330208716&amp;url_flg=0&amp;url=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html&amp;title=%E5%89%8D%E6%A9%8B%E5%B8%82%E3%81%AE%E3%83%94%E3%83%B3%E3%83%9D%E3%82%A4%E3%83%B3%E3%83%88%E5%A4%A9%E6%B0%97%20-%20%E6%97%A5%E6%9C%AC%E6%B0%97%E8%B1%A1%E5%8D%94%E4%BC%9A%20tenki.jp&amp;keywords=%E5%A4%A9%E6%B0%97%2C%E5%A4%A9%E6%B0%97%E4%BA%88%E5%A0%B1%2Ctenki.jp%2C%E7%81%BD%E5%AE%B3&amp;description=%E7%BE%A4%E9%A6%AC%E7%9C%8C%20%E5%89%8D%E6%A9%8B%E5%B8%82%E3%81%AE%E3%83%94%E3%83%B3%E3%83%9D%E3%82%A4%E3%83%B3%E3%83%88%E5%A4%A9%E6%B0%97%E3%80%823%E6%99%82%E9%96%93%E6%AF%8E%E3%81%AB%E6%9C%80%E5%A4%A748%E6%99%82%E9%96%93%E5%85%88%E3%81%BE%E3%81%A7%E3%81%AE%E5%A4%A9%E6%B0%97%E3%83%BB%E6%B0%97%E6%B8%A9%E3%83%BB%E9%99%8D%E6%B0%B4%E9%87%8F%E3%83%BB%E9%A2%A8%E5%90%91%E3%83%BB%E9%A2%A8%E9%80%9F%E3%83%BB%E6%B9%BF%E5%BA%A6%E3%81%AE%E4%BA%88%E6%B8%AC%E3%81%A8%E3%80%8110%E6%97%A5%E9%96%93%E3%81%AE%E5%A4%A9%E6%B0%97%E4%BA%88%E5%A0%B1%E3%81%8C%E7%A2%BA%E8%AA%8D%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%99%E3%80%82" name="deqwas-k_null" style="width:0px;height:0px;" width="0px" height="0px" frameborder="0" scrolling="no">
/iframe>
/div>
div id="deqwas-k">
script src="http://mark003.deqwas.net/tenki/scripts/category.js?noCache=1406330208619" type="text/javascript" defer="" charset="UTF-8">
/script>
script src="http://mark003.deqwas.net/common/scripts/DeqwasAgent.js?noCache=1406330208702" defer="" charset="UTF-8">
/script>
/div>
script type="text/javascript">
//
![CDATA[
    var deqwas_k = { option: {} };

    deqwas_k.directory = 'forecast';
    deqwas_k.category  = 'トップ/関東・甲信地方/群馬県';
    deqwas_k.location  = '群馬県';

    (function () {
        var script = document.createElement('script');
        script.src = (location.protocol == 'https:' ? 'https:' : 'http:') + '//mark003.deqwas.net/tenki/scripts/category.js?noCache=' + new Date().getTime();
        script.type = 'text/javascript';
        script.defer = true;
        script.charset = 'UTF-8';
        document.getElementById('deqwas-k').appendChild(script);
    })();
//]]>
/script>
!-- /deqwas.net category 2012/12/21 -->



!-- adfunnel.microad.jp 2013/07/29 -->
!-- #large_rectangle_bottom -->
div id="large_rectangle_bottom" class="ad-large-lectangle">
!--/* adfunnel.microad.jp Javascript Tag v */-->

script type="text/javascript">
!--//
![CDATA[
   document.MAX_ct0 ='INSERT_CLICKURL_HERE';

if (location.protocol=='https:') {
} else {
   var m3_u = 'http://adf.send.microad.jp/ajs.php';
   var m3_r = Math.floor(Math.random()*99999999999);
   if (!document.MAX_used) document.MAX_used = ',';
   document.write ("
scr"+"ipt type='text/javascript' src='"+m3_u);
   document.write ("?zoneid=14271");
   document.write ('&amp;snr=1&amp;cb=' + m3_r);
   if (document.MAX_used != ',') document.write ("&amp;exclude=" + document.MAX_used);
   document.write (document.charset ? '&amp;charset='+document.charset : (document.characterSet ? '&amp;charset='+document.characterSet : ''));
   document.write ("&amp;loc=" + encodeURIComponent(window.location));
   if (document.referrer) document.write ("&amp;referer=" + encodeURIComponent(document.referrer));
   if (document.context) document.write ("&context=" + encodeURIComponent(document.context));
   if ((typeof(document.MAX_ct0) != 'undefined') && (document.MAX_ct0.substring(0,4) == 'http')) {
       document.write ("&amp;ct0=" + encodeURIComponent(document.MAX_ct0));
   }
   if (document.mmm_fo) document.write ("&amp;mmm_fo=1");
   document.write ("'>
\/scr"+"ipt>");
}
//]]>-->
/script>
script type="text/javascript" src="http://adf.send.microad.jp/ajs.php?zoneid=14271&amp;snr=1&amp;cb=83298483396&amp;charset=UTF-8&amp;loc=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html">
/script>
!--/* OpenX IFrame tag */-->
iframe id="529c3bf8f3434" name="529c3bf8f3434" src="http://servedby.openxmarket.jp/w/1.0/afr?auid=464989&amp;cb=INSERT_RANDOM_NUMBER_HERE" frameborder="0" framespacing="0" scrolling="no" width="300" height="250">&lt;a href="http://adf.send.microad.jp/ck.php?oaparams=2__bannerid=56813__snr=1__zoneid=14271__OXLCA=1__cb=cf47822481__t=1406330206.6216__oadest=http%3A%2F%2Fservedby.openxmarket.jp%2Fw%2F1.0%2Frc%3Fcs%3D529c3bf8f3434%26cb%3DINSERT_RANDOM_NUMBER_HERE" target="_blank"&gt;&lt;img src="http://servedby.openxmarket.jp/w/1.0/ai?auid=464989&amp;cs=529c3bf8f3434&amp;cb=INSERT_RANDOM_NUMBER_HERE" border="0" alt=""&gt;&lt;/a&gt;
/iframe>
div id="beacon_cf47822481" style="position: absolute; left: 0px; top: 0px; visibility: hidden;">
img src="http://adf.send.microad.jp/lg.php?bannerid=56813&amp;campaignid=3434&amp;zoneid=14271&amp;cb=cf47822481&amp;t=1406330206.6216&amp;snr=1" width="0" height="0" alt="" style="width: 0px; height: 0px;">
/div>
noscript>&lt;a href='http://adf.send.microad.jp/ck.php?n=a6c97d21&amp;amp;cb=INSERT_RANDOM_NUMBER_HERE' target='_blank'&gt;&lt;img src='http://adf.send.microad.jp/avw.php?zoneid=14271&amp;amp;cb=INSERT_RANDOM_NUMBER_HERE&amp;amp;n=a6c97d21&amp;amp;ct0=INSERT_CLICKURL_HERE&amp;amp;snr=1' border='0' alt='' /&gt;&lt;/a&gt;
/noscript>
/div>
!-- /#large_rectangle_bottom -->
!-- /adfunnel.microad.jp 2013/07/29 -->


/div>
!-- /#bd-sub -->

/div>
!-- /#bd -->

!-- #ft-list-official -->
div id="ft-list-official">
    
div id="ft-list-external" class="clearfix">
        
ul class="ft-list-external-unit clearfix">
            
li class="ft-list-external-title">
a href="http://www.tenki.jp/docs/iphone/" target="_blank">iPhoneアプリ
/a>
/li>
            
li class="ft-list-external-icon">
a href="http://www.tenki.jp/docs/iphone/" target="_blank">
img src="http://az416740.vo.msecnd.net/images/contents/common/banner/tenkijp_iphone_40_40.gif" width="40" height="40" alt="iPhoneアプリ">
/a>
/li>
            
li class="ft-list-external-text">「今、この場所で知りたい！」に答えました
/li>
        
/ul>
        
ul class="ft-list-external-unit clearfix">
            
li class="ft-list-external-title">
a href="http://www.tenki.jp/lite/" target="_blank">スマートフォン
/a>
/li>
            
li class="ft-list-external-icon">
a href="http://www.tenki.jp/lite/" target="_blank">
img src="http://az416740.vo.msecnd.net/images/contents/common/banner/tenkijp_smartphone_40_40.gif" width="40" height="40" alt="スマートフォン">
/a>
/li>
            
li class="ft-list-external-text">スマートフォン版に最適化されたtenki.jp
/li>
        
/ul>
        
ul class="ft-list-external-unit clearfix">
            
li class="ft-list-external-title">
a href="http://www.tenki.jp/docs/twitter/" target="_blank">Twitter
/a>
/li>
            
li class="ft-list-external-icon">
a href="http://www.tenki.jp/docs/twitter/" target="_blank">
img src="http://az416740.vo.msecnd.net/images/contents/common/banner/tenkijp_twitter_40_40.gif" width="40" height="40" alt="Twitter">
/a>
/li>
            
li class="ft-list-external-text">100万フォロワーを超えました
/li>
        
/ul>
        
ul class="ft-list-external-unit clearfix">
            
li class="ft-list-external-title">
a href="http://www.facebook.com/tenkijp" target="_blank">facebook
/a>
/li>
            
li class="ft-list-external-icon">
a href="http://www.facebook.com/tenkijp" target="_blank">
img src="http://az416740.vo.msecnd.net/images/contents/common/banner/tenkijp_facebook_40_40.gif" width="40" height="40" alt="facebook">
/a>
/li>
            
li class="ft-list-external-text">気象予報士がタイムリーに話題提供
/li>
        
/ul>
        
ul class="ft-list-external-unit-last clearfix">
            
li class="ft-list-external-title">
a href="http://apps.microsoft.com/windows/ja-jp/app/tenki-jp/bee7c703-116e-4842-b668-2c4ec92ba63a" target="_blank">Winストア
/a>
/li>
            
li class="ft-list-external-icon">
a href="http://apps.microsoft.com/windows/ja-jp/app/tenki-jp/bee7c703-116e-4842-b668-2c4ec92ba63a" target="_blank">
img src="http://az416740.vo.msecnd.net/images/contents/common/banner/tenkijp_windows8_40_40.gif" width="40" height="40" alt="Winストア">
/a>
/li>
            
li class="ft-list-external-text">Windows8アプリならではの動作を実現
/li>
        
/ul>
    
/div>
/div>
!--/#ft-list-official-->


!-- ft/contents_menu.incmap_city_id:58 map_city_name:南部（前橋） ## generate at 2014-06-30 23:57:51 -->
div id="ft-contents-menu" class="ft-contents-menu clearfix clear">
h3 id="ft-contents-title">群馬県 南部(前橋)のコンテンツ
/h3>
h3 id="ft-contents-top-link">
a href="http://www.tenki.jp/">tenki.jpトップ
/a>
/h3>

div id="ft-contents-menu-wrap">

div id="ft-contents-menu-forecast" class="ft-contents-menu-entry active">
  
h3>天気予報
/h3>
  
ul>
    
li class="active">
a href="">天気予報
/a>
/li>
    
li>
a href="http://www.tenki.jp/world/">世界天気
/a>
/li>




    
li>
a href="http://www.tenki.jp/forecaster/diary/">日直予報士
/a>
/li>

    
li>
a href="http://www.tenki.jp/long/10300.html">長期予報
/a>
/li>

    
li>
a href="http://www.tenki.jp/radar/3/13/rainmesh.html">雨雲(予報)
/a>
/li>

    
li>
a href="http://www.tenki.jp/particulate_matter/">PM2.5分布予測
/a>
/li>
  
/ul>
/div>

div id="ft-contents-menu-weatherguide" class="ft-contents-menu-entry">
  
h3>観測
/h3>
  
ul>
    
li>
a href="http://www.tenki.jp/radar/3/13/">雨雲(実況)
/a>
/li>
    
li>
a href="http://www.tenki.jp/amedas/3/13/">アメダス実況
/a>
/li>
    
li>
a href="http://www.tenki.jp/live/3/13/">実況天気
/a>
/li>
    
li>
a href="http://www.tenki.jp/past/?map_pref_id=13&amp;jma_code=47624">過去天気
/a>
/li>
  
/ul>
/div>


div id="ft-contents-menu-disaster" class="ft-contents-menu-entry">
  
h3>防災情報
/h3>
  
ul>
    
li>
a href="http://www.tenki.jp/bousai/warn/3/13/">警報・注意報
/a>
/li>
    
li>
a href="http://www.tenki.jp/bousai/earthquake/">地震情報
/a>
/li>
    
li>
a href="http://www.tenki.jp/bousai/tsunami/">津波情報
/a>
/li>
    
li>
a href="http://www.tenki.jp/bousai/volcano/">火山情報
/a>
/li>
    
li>
a href="http://www.tenki.jp/bousai/typhoon/">台風情報
/a>
/li>
  
/ul>
/div>


div id="ft-contents-menu-chart" class="ft-contents-menu-entry">
  
h3>天気図
/h3>
  
ul>
    
li>
a href="http://www.tenki.jp/guide/chart/">天気図
/a>
/li>
    
li>
a href="http://www.tenki.jp/satellite/japan_east/">気象衛星
/a>
/li>
    
li>
a href="http://www.tenki.jp/satellite/world/">世界衛星
/a>
/li>
  
/ul>
/div>

div id="ft-contents-menu-indexes" class="ft-contents-menu-entry clearfix">
  
h3>指数情報
/h3>

  
div class="ft-contents-menu-entry-indexes">
    
h4>通年
/h4>
    
ul>
      
li>
a href="http://www.tenki.jp/indexes/cloth_dried/3/13/4210.html">洗濯
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/dress/3/13/4210.html">服装
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/odekake/3/13/4210.html">お出かけ
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/starry_sky/3/13/4210.html">星空
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/umbrella/3/13/4210.html">傘
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/uv_index_ranking/3/13/4210.html">紫外線
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/self_temp/3/13/4210.html">体感温度
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/carwashing/3/13/4210.html">洗車
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/leisure/3/13/4210.html">レジャー
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/throat_lozenge/3/13/4210.html">のど飴
/a>
/li>
    
/ul>
  
/div>

  
div class="ft-contents-menu-entry-indexes">
    
h4>夏季
/h4>
    
ul>
      
li>
a href="http://www.tenki.jp/indexes/sweat/3/13/4210.html">汗かき
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/discomfort/3/13/4210.html">不快
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/reibo/3/13/4210.html">冷房
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/ice_cream/3/13/4210.html">アイス
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/beer/3/13/4210.html">ビール
/a>
/li>
      
li>
a href="http://www.tenki.jp/indexes/disinfect/3/13/4210.html">除菌
/a>
/li>
    
/ul>
  
/div>

/div>


div id="ft-contents-menu-leisure" class="ft-contents-menu-entry">
  
h3>レジャー天気
/h3>
  
ul>
    
li>
a href="http://www.tenki.jp/mountain/">山の天気
/a>
/li>
    
li>
a href="http://www.tenki.jp/wave/3/">海の天気
/a>
/li>
    
li>
a href="http://www.tenki.jp/leisure/airport/3/13/">空港
/a>
/li>
    
li>
a href="http://www.tenki.jp/leisure/baseball/3/13/">野球場
/a>
/li>
    
li>
a href="http://www.tenki.jp/leisure/soccer/3/13/">サッカー場
/a>
/li>
    
li>
a href="http://www.tenki.jp/leisure/golf/3/13/">ゴルフ場
/a>
/li>
    
li>
a href="http://www.tenki.jp/leisure/camp/3/13/">キャンプ場
/a>
/li>
    
li>
a href="http://www.tenki.jp/leisure/horse/3/13/">競馬・競艇・競輪
/a>
/li>
    
li>
a href="http://www.tenki.jp/leisure/fishing/3/13/">釣り
/a>
/li>
    
li>
a href="http://www.tenki.jp/leisure/park/3/13/">テーマパーク
/a>
/li>

  
/ul>
/div>


div id="ft-contents-menu-season" class="ft-contents-menu-entry">
  
h3>季節特集
/h3>
  
ul>
   
li>
a href="http://www.tenki.jp/pollen/3/13/">花粉情報
/a>
span>(1～5月頃)
/span>
/li>
   
li>
a href="http://www.tenki.jp/sakura/3/13/">桜情報
/a>
span>(2～5月頃)
/span>
/li>
   
li>
a href="http://www.tenki.jp/heatstroke/3/13/4210.html">熱中症情報
/a>
span>(4～9月頃)
/span>
/li>
   
li>
a href="http://www.tenki.jp/kouyou/3/13/">紅葉情報
/a>
span>(10～11月頃)
/span>
/li>
   
li>
a href="http://www.tenki.jp/season/ski/3/13/&amp;item=name_yomi">スキー情報
/a>
span>(11～5月頃)
/span>
/li>  
/ul>
/div>


div id="ft-contents-menu-labo" class="ft-contents-menu-entry">
  
h3>tenki.jpラボ
/h3>
  
ul>
    
li>
a href="http://www.tenki.jp/labo/">tenki.jpラボ
/a>
/li>
  
/ul>
/div>


/div>
!-- #ft-contents-menu-wrap -->

/div>
!-- #ft-contents-menu -->
!-- /ft/contents_menu.incmap_city_id:58 map_city_name:南部（前橋） -->


!--  #ft  -->
div id="ft">
  
p id="ft-page-top">
a href="#container">このページの先頭へ
/a>
/p>
  
ul id="ft-menu" class="clearfix">
    
li>
a href="http://www.jwa.or.jp/corporate/" target="_blank">会社概要
/a>
/li>
    
li>
a href="http://www.tenki.jp/docs/rule">利用規約
/a>
/li>
    
li>
a href="http://www.tenki.jp/docs/privacypolicy">プライバシーポリシー
/a>
/li>
    
li>
a href="http://www.tenki.jp/docs/advertise">広告掲載
/a>
/li>
    
li>
a href="https://cms.tenki.jp/cms/inquiry/">お問い合わせ
/a>
/li>
    
li class="last">Produced by 
a href="http://www.jwa.or.jp/">JWA
/a> &amp; 
a href="http://www.alink.ne.jp/">ALiNK
/a>
/li>
  
/ul>
  
p id="ft-copyright">Copyright (C) 2014 日本気象協会 All Rights Reserved.
/p>
/div>
!--  /#ft  -->


/div>
!-- /#container -->

!--  dnpdmp 2014/07/01 -->
script type="text/javascript">
if(typeof dmids == "undefined"){var dmids = {}};
dmids["a619af40541e5740"] = "j.dnpdmp.jp";
/script>
script src="//j.dnpdmp.jp/js/dc.js" type="text/javascript">
/script>
!-- /dnpdmp 2014/07/01 -->

!-- AD.com japan audience tag 2012/06/26 -->
script language="JavaScript">var tcdacmd="dt";
/script>
script src="http://an.tacoda.net/an/18399/slf.js" language="JavaScript">
/script>
script src="http://tacoda.at.atwola.com/rtx/r.js?cmd=FPX&amp;si=18399&amp;pi=&amp;xs=3&amp;pu=http%253A%252F%252Fwww.tenki.jp%252Fforecast%252F3%252F13%252F4210%252F10201.html%253Fifu%253D%2526cmmiss%253D-1%2526cmkw%253D%2526lstr%253D&amp;r=www.tenki.jp&amp;atsync=1&amp;bf=1&amp;acf=1&amp;btf=1&amp;adf=1&amp;v=6.4.6&amp;cb=20735" language="JavaScript">
/script>
img src="http://leadback.advertising.com/adcedge/lb?site=695501&amp;betr=tc=0|bk=0&amp;guidm=1:19t5pav1iasoi4&amp;bnum=20002" style="display: none" height="1" width="1" border="0">
!-- /AD.com japan audience tag 2012/06/26 -->

!-- User Insight PCDF Code Start : tenki.jp -->
script type="text/javascript">
!--
var _uic = _uic ||{}; var _uih = _uih ||{};_uih['id'] = 31873;
_uih['lg_id'] = '';
_uih['fb_id'] = '';
_uih['tw_id'] = '';
_uih['uigr_1'] = ''; _uih['uigr_2'] = ''; _uih['uigr_3'] = ''; _uih['uigr_4'] = ''; _uih['uigr_5'] = '';
_uih['uigr_6'] = ''; _uih['uigr_7'] = ''; _uih['uigr_8'] = ''; _uih['uigr_9'] = ''; _uih['uigr_10'] = '';

/* DO NOT ALTER BELOW THIS LINE */
/* WITH FIRST PARTY COOKIE */
(function() {
var bi = document.createElement('scri'+'pt');bi.type = 'text/javascript'; bi.async = true;
bi.src = ('https:' == document.location.protocol ? 'https://bs' : 'http://c') + '.nakanohito.jp/b3/bi.js';
var s = document.getElementsByTagName('scri'+'pt')[0];s.parentNode.insertBefore(bi, s);
})();
//-->
/script>
!-- User Insight PCDF Code End : tenki.jp -->

!-- owldata 2013/12/19 -->
script type="text/javascript">
if(typeof dmids == "undefined"){var dmids = {}};
dmids["17ed859f157263ff79f9018e0fb7ca85"] = "j.owldata.com";
/script>
script src="//j.owldata.com/js/d.js" type="text/javascript">
/script>
!-- /owldata 2013/12/19 -->

script language="JavaScript" type="text/javascript" src="//o.advg.jp/ojs?aid=5172&amp;pid=17" charset="UTF-8">
/script>
script language="javascript" type="text/javascript" src="http://o.advg.jp/ojs2?aid=5172&amp;pid=17&amp;_url=http%3A//www.tenki.jp/forecast/3/13/4210/10201.html&amp;_nocache=14063302092555383085" charset="UTF-8">
/script>
script language="javascript" type="text/javascript" src="http://dex.advg.jp/dx/p/mark0?_aid=27&amp;_page=49">
/script>
img width="1" height="1" style="display: none; " src="http://c03.nakanohito.jp/b3/?uisv=3&amp;from=ui3&amp;id=31873&amp;mode=default&amp;rand=1030151&amp;url=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html&amp;sb=%E5%89%8D%E6%A9%8B%E5%B8%82%E3%81%AE%E3%83%94%E3%83%B3%E3%83%9D%E3%82%A4%E3%83%B3%E3%83%88%E5%A4%A9%E6%B0%97%20-%20%E6%97%A5%E6%9C%AC%E6%B0%97%E8%B1%A1%E5%8D%94%E4%BC%9A%20tenki.jp&amp;bw=400&amp;bh=300&amp;sw=1024&amp;sh=768&amp;dpr=1&amp;fp=201407260816498215&amp;count=1&amp;eflg=1">
script language="javascript" type="text/javascript" src="http://dex.advg.jp/dx/p/mark?_aid=27&amp;_page=49&amp;_url=http%3A//www.tenki.jp/forecast/3/13/4210/10201.html&amp;_withsync=1&amp;_nocache=140633020943731591260">
/script>
script language="javascript" type="text/javascript" src="//dex.advg.jp/dx/p/sync0?_aid=111&amp;_page=441">
/script>
script language="javascript" type="text/javascript" src="http://dex.advg.jp/dx/p/scheck?_aid=111&amp;_page=441&amp;_url=http%3A//www.tenki.jp/forecast/3/13/4210/10201.html&amp;_withsync=1&amp;_nocache=140633020945666446082">
/script>
img src="//cm.g.doubleclick.net/pixel?google_nid=plid&amp;google_cm&amp;_aid=111&amp;_page=441" width="1" height="1">
img src="//jp-u.openx.net/w/1.0/cm?id=bf627b5d-c18f-8607-675e-699621a8b259&amp;r=%2f%2fdex%2eadvg%2ejp%2fdx%2fp%2fsync%3f_aid%3d111%26_page%3d1112%26exuid%3d" width="1" height="1">
!-- Google Code for tenki_&#32676;&#39340; -->
!-- Remarketing tags may not be associated with personally identifiable information or placed on pages related to sensitive categories. For instructions on adding this tag and more information on the above requirements, read the setup guide: google.com/ads/remarketingsetup -->
script type="text/javascript">
/* 
![CDATA[ */
var google_conversion_id = 999603484;
var google_conversion_label = "BdgoCMSPsgQQnPrS3AM";
var google_custom_params = window.google_tag_params;
var google_remarketing_only = true;
/* ]]> */
/script>
script type="text/javascript" src="//www.googleadservices.com/pagead/conversion.js">
/script>
iframe name="google_conversion_frame" title="Google conversion frame" width="300" height="13" src="http://googleads.g.doubleclick.net/pagead/viewthroughconversion/999603484/?random=1406330209530&amp;cv=7&amp;fst=1406330209530&amp;num=1&amp;fmt=1&amp;label=BdgoCMSPsgQQnPrS3AM&amp;guid=ON&amp;u_h=768&amp;u_w=1024&amp;u_ah=768&amp;u_aw=1024&amp;u_cd=32&amp;u_his=1&amp;u_tz=540&amp;u_java=false&amp;u_nplug=0&amp;u_nmime=0&amp;frm=0&amp;url=http%3A//www.tenki.jp/forecast/3/13/4210/10201.html" frameborder="0" marginwidth="0" marginheight="0" vspace="0" hspace="0" allowtransparency="true" scrolling="no">&lt;img height="1" width="1" border="0" alt="" src="http://googleads.g.doubleclick.net/pagead/viewthroughconversion/999603484/?frame=0&amp;random=1406330209530&amp;cv=7&amp;fst=1406330209530&amp;num=1&amp;fmt=1&amp;label=BdgoCMSPsgQQnPrS3AM&amp;guid=ON&amp;u_h=768&amp;u_w=1024&amp;u_ah=768&amp;u_aw=1024&amp;u_cd=32&amp;u_his=1&amp;u_tz=540&amp;u_java=false&amp;u_nplug=0&amp;u_nmime=0&amp;frm=0&amp;url=http%3A//www.tenki.jp/forecast/3/13/4210/10201.html" /&gt;
/iframe>
noscript>
&lt;div style="display:inline;"&gt;
&lt;img height="1" width="1" style="border-style:none;" alt="" src="//googleads.g.doubleclick.net/pagead/viewthroughconversion/999603484/?value=0&amp;amp;label=BdgoCMSPsgQQnPrS3AM&amp;amp;guid=ON&amp;amp;script=0"/&gt;
&lt;/div&gt;
/noscript>
script type="text/javascript" src="//m.dtpf.jp/dx/mark0?cid=17&amp;pid=1">
/script>

noscript>
&lt;iframe src="//o.advg.jp/oif?aid=5172&amp;pid=17" width="1" height="1"&gt;
&lt;/iframe&gt;
/noscript>


!-- ClickTale Bottom part -->

script type="text/javascript">
// The ClickTale Balkan Tracking Code may be programmatically customized using hooks:
// 
//   function ClickTalePreRecordingHook() { /* place your customized code here */  }
//
// For details about ClickTale hooks, please consult the wiki page http://wiki.clicktale.com/Article/Customizing_code_version_2

document.write(unescape("%3Cscript%20src='"+
(document.location.protocol=='https:'?
"https://cdnssl.clicktale.net/www14/ptc/4b4d144b-209b-4a9a-aef5-1548008a1d76.js":
"http://cdn.clicktale.net/www14/ptc/4b4d144b-209b-4a9a-aef5-1548008a1d76.js")+"'%20type='text/javascript'%3E%3C/script%3E"));
/script>
script src="http://cdn.clicktale.net/www14/ptc/4b4d144b-209b-4a9a-aef5-1548008a1d76.js" type="text/javascript">
/script>
div id="ClickTaleDiv" style="display: none;">
/div>
script src="http://cdn.clicktale.net/www/tc/WRe15.js" type="text/javascript">
/script>

!-- ClickTale end of Bottom part -->



!-- /component/forecast/template/point_10201.html ## generate at 2014-07-23 12:07:56 -->
script src="http://dmp.gmodmp.jp/seg/?dmid=a7ab697a26801a71&amp;url=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html&amp;ref=&amp;carriertype=1">
/script>
script src="http://dmp.dnpdmp.jp/seg/?dmid=a619af40541e5740&amp;ac_al=0&amp;url=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html&amp;ref=&amp;carriertype=1">
/script>
script src="http://dmp.owldata.com/seg/?dmid=17ed859f157263ff79f9018e0fb7ca85&amp;ac_al=0&amp;ac_lsr=1&amp;url=http%3A%2F%2Fwww.tenki.jp%2Fforecast%2F3%2F13%2F4210%2F10201.html&amp;ref=&amp;carriertype=1">
/script>
iframe style="position: absolute; top: -999px; left: -999px; " src="http://j.gmodmp.jp/js/dmp_kauli.html?sks=22:1384:1">
/iframe>
/body>
/html>

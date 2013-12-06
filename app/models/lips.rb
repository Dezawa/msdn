# -*- coding: utf-8 -*-
class Lips #< ActiveRecord::Base
  #include 'Error/error'
  #require 'jcode'
  require 'csv'
  require 'nkf'
  require 'pp'
  attr_accessor :min,:max,:promax,:opemax,:vertical,:minmax,:download,:profit,
              :proname,:gele,:opename,:gain,:time,:rate,:pro,:ope,:errors

  def initialize(params=nil)
    #defaulte value:
    @errors = Error::Errors.new(self)
   if params
      @promax = params[:promax] ?  params[:promax].to_i : 10
      @opemax = params[:opemax] ?  params[:opemax].to_i : 10
   else
     @promax=@opemax = 10
   end
    @vertical,@minmax,@download,@profit=["landscape","maximize","0",nil]
    @proname,@opename,@gele = [Array.new(@promax+1,""),Array.new(@opemax+1,""),Array.new(@opemax+1,"")]
    @time,@pro,@ope,@gain,@min,@max = 
     [@time,@pro,@ope,@gain,@min,@max].map{|i| Array.new(@opemax+1,0.0) }
    @rate = (0..@promax).map{|pro| (0..@opemax).map{|ope| 0.0 }}
    if params
      [:proname,:opename,:gele].each{|sym|
        if params[sym]
          #self.send(:pronameset,%(ff hh ll))
          klass =  params[sym].class
          if klass == HashWithIndifferentAccess or klass == Hash
            params[sym].each_pair{|i,v| self.send(sym.to_s+"set",v,i.to_i)
            }
          elsif klass== Array ;self.send(sym.to_s+"set",params[sym])
          end
        end
      }
     [:gain,:time,:pro,:ope,:min,:max].each{|sym|
        if params[sym]
          #self.send(:pronameset,%(ff hh ll))
          klass =  params[sym].class
          if klass == HashWithIndifferentAccess or klass == Hash
            params[sym].each_pair{|i,v| self.send(sym.to_s+"set",v.to_f,i.to_i)
            }
          elsif klass== Array ;self.send(sym.to_s+"set",params[sym].map{|v| v.to_f})
          end
        end
      }
      if rate=params[:rate]
        klass = rate.class
        if klass == HashWithIndifferentAccess or klass == Hash
          #pp rate
          rate.each_pair{|i,v|
            if (kklass = v.class)==HashWithIndifferentAccess or kklass == Hash
              v.each_pair{|j,vv| self.rateset(vv.to_f,i.to_i,j.to_i)
              }
            end
          }
        elsif klass== Array ;self.rateset(params[sym])
        end
      end
      [:vertical,:minmax,:download].each{|sym|
        self.send(sym.to_s+"set",params[sym]) if params[sym] 
      }
    end
  end

  def t(sym,lang=nil)
    I18n.locale(lang) if lang
    I18n.t sym
  end

  def profitset(val) ; @profit=val  ; end
  def promaxset(val) ; @promax=val  ; end
  def opemaxset(val) ; @opemax=val  ; end
  def verticalset(val) ; @vertical=val  ; end
  def minmaxset(val) ; @minmax=val  ; end
  def downloadset(val) ; @download=val  ; end
  def pronameset(val,i=nil)    ; if i ;@proname[i]=val;else; @proname=val  ; end; end
  def openameset(val,i=nil)    ; if i ;@opename[i]=val;else; @opename=val  ; end; end
  def gainset(val,i=nil)       ; if i ;@gain[i]   =val;else; @gain=val    ; end; end
  def timeset(val,i=nil)       ; if i ;@time[i]   =val;else; @time=val    ;  end; end
  def minset(val,i=nil)        ; if i ;@min[i]    =val;else; @min=val     ;  end; end
  def maxset(val,i=nil)        ; if i ;@max[i]    =val;else; @max=val     ;  end; end
  def rateset(val,i=nil,j=nil) ; if i ;@rate[i][j]=val;else; @rate=val    ; end; end
  def proset(val,i=nil)        ; if i ;@pro[i]    =val;else; @pro=val     ;  end; end
  def opeset(val,i=nil)        ; if i ;@ope[i]    =val;else; @ope=val     ; end; end
  def geleset(val,i=nil)       ; if i ;@gele[i]   =val;else; @gele=val    ; end; end
 
  # prefix, 　結果CSVファイルの置き場 最後に "/"
  # filebase  計算用のファイルのbasename
  # csvfile　 結果CSVファイルのファイル名
  def calc(prefix,filebase,csvfile)
    filepath ="/tmp/"+filebase
    @promaxclass = @promax.class
    ## 利益、最小、最大
    items = (1..@promax).map{|p| 
      if @proname[p]=="" ; nil
      else
        @errors.add( :gain,"#{@proname[p]}の"+ t(:profit)+"が入力されていません") if @gain[p]==0.0
        #   v=@lips[m][p] 
        # }
        max = @max[p] == 0.0 ? "10000000" : @max[p].to_s
        [p.to_s,@gain[p].to_s,@min[p].to_s,max].join(" ")
      end
    }.compact
    promax = items.size
    @errors.add(:proname,t(:pro_name)+"が一つも定義されていません") if promax == 0
    #puts items.size
    rate = (1..@promax).map{|p| 
      if  @proname[p]=="" ; nil
      else
        r= (1..@opemax).map{|op| 
          if @opename[op] =="" ; nil
          else
            @gele[op] == "<=" ? @rate[p][op].to_s : "-" + @rate[p][op].to_s
          end
        }.compact.join(" ")
        @errors.add( :rate ,
                     "#{@proname[p]}の「#{t(:coment)}」が一つも定義されていません"
                    ) unless /[1-9]/ =~ r

        p.to_s+" "+r
      end
    }.compact

    #puts rate.join
    # 工程の制約
    times =(1..@opemax).map{|op| 
      if @opename[op]=="" ; nil
      else
        @errors.add(:time,"#{@opename[op]}の#{t :runtime}が定義されていません") if @time[op] == 0.0 
        time = @gele[op]=="<=" ? @time[op] : -(@time[op])
        [op.to_s,time.to_s].join(" ")
      end
    }.compact
    opemax = times.size
    mod=open("#{filepath}.data","w")
    mod.printf "data;\nparam n := %d ;\nparam m := %d ;\n",promax,opemax
    mod.print  "param item : 1 2 3 :=\n"
    mod.puts   items,";"
    mod.puts   "param rate : #{(1..opemax).to_a.join(' ')} :="
    mod.puts   rate ,";"
    mod.puts   "param time :="
    mod.puts   times," ;"
    mod.close
    ####
    #### シミュレート
    pid = fork{
      exec("/usr/bin/glpsol -m /opt/MSDN/LiPS/LinierPlan_#{minmax}.mod -d #{filepath}.data -o #{filepath}.sol>#{filepath}.log")
    }   
    if pid
      Process.waitall
    end 
    ######### 結果読み込み
    begin
      sol = File.read("#{filepath}.sol")
    rescue  
      @errors.add_to_base("計算に失敗しました") 
      return
    end
    para = {}
    sol =~ /Objective:\s+z\s+=\s*(\d+)/
    @profit=$1
    sol=sol.split(/[\r\n]+/) 

    until sol.shift =~ /^-+/;end
    #----- ------------ -- ------------- ------------- ------------- -------------
    #sol.shift
    # 1 z            B           9600                             
    # 2 mx[1]        B            160                       1e+07 
    # 6 ope[1]       B           2400                        2400 
    while (line = sol.shift) =~ /^\s+\d/
      if line =~ /^\s+\d+\s+(\w+)\[(\d+)\]\s+\w+\s+([-+\.\.\de]+)/
        self.send( $1+"set",$3.to_f,$2.to_i) if $1 == "ope"
      end
    end  
    
    until sol.shift =~ /^-+/ ; end
    #------ ------------ -- ------------- ------------- ------------- -------------
    #     1 pro[1]       B            160             0               
    while (line = sol.shift) =~ /^\s+\d/
      if line =~ /^\s+\d+\s+(\w+)\[(\d+)\]\s+\w+\s+([-+\.\.\de]+)/
        self.send( $1+"set",$3.to_f,$2.to_i)
      end
    end  
    (1..@opemax).each{|ope|  @ope[ope] = -@ope[ope] if @gele[ope] == ">=" }
    csvout(prefix+csvfile)

    self
  end # of def cals

  def Lips.params2lips(params)
    #lips_"=>{
    #     "minmax"=>"maximize", "opemax"=>"10", "promax"=>"10", "vertical"=>"landscape",
    #    "gele_1"=>"<=",  "gele_2"=>"<=", "gain_1"=>"","gain_2"=>"", "max_1"=>"", "max_2"=>"",
    #     "min_1"=>"", "min_2"=>"", "opename_1"=>"", "opename_2"=>"", "proname_1"=>"", "proname_2"=>"",
    #     "rate_1_1"=>"", "rate_1_2"=>"", "rate_2_1"=>"", "rate_2_2"=>"", "time_1"=>"", "time_2"=>"",
    #  }
    floats = %w(minmax opemax promax max min rate time)
    strings = %w(vertical gele opename proname)
    lips = HashWithIndifferentAccess.new
    params.each_pair{|key,val|
      sym,i,j = ary = key.split("_")
      i = i.to_i ; j=j.to_i ; float = floats.include?(sym)
      case ary.size
      when 1 ; lips[sym] =  (float ? val.to_f : val)
      when 2 ; lips[sym] ||= [] ; lips[sym][i] = (float ? val.to_f : val )
      when 3 ; lips[sym] ||= [] ; lips[sym][i] ||= [] ; lips[sym][i][j]=(float ? val.to_f : val)
      end
    }
    lips

  end
  def csvout(csvfile)
    minmax =  @minmax =="maximize" ? "最大値" : "最小値"
   # @vertical="vertical"
    ### 表本体表示 ########################################
    csv = "LiPS-CSV-H,Ver1.00,線型計画法計算[LiPS #{t :lips}] 結果　(#{minmax}),\n"
    csv << "このファイルはUploadできます。\n"	

    if @vertical =="landscape"
      csv << "最大化/最小化,#{minmax},,,"+t(:pro_name)+"," 
      csv << @proname[1..-1].join(",") << "\n"
      csv << "t(:profit)},#{@profit},,,#{t(:pro_gain)},"
      csv <<  @gain[1..-1].join(",") << "\n"
      csv << ",,,,#{t(:min)}," << @min[1..-1].join(",") << "\n"
      csv << ",,,,#{t(:max)}," << @max[1..-1].join(",") << "\n"
      csv << ",,,,#{t(:number)},"     << @pro[1..-1].join(",") << "\n"
      csv << "#{t :operation},#{t :runtime},≦≧,実稼働,稼働率,#{t :coment}\n"
      
      (1..@opemax).each{|ope|  #ope0="ope#{ope}" ; time ="time#{ope}"; gele="gele#{ope}"
        v=@time[ope].to_f
        if v==0.0 ; vv="" ; else ; vv= sprintf("%4.1f%%",100 * ( @ope[ope].to_f/v.to_f));end
        gele = @gele[ope] == ">="  ? "以上" : "以下"
        csv << "#{@opename[ope]},#{@time[ope]},#{gele},#{v},#{vv},"
        csv << (1..@promax).map{|pro| @rate[pro][ope] }.join(",")  << "\n"
      }
      
    else # 製品縦 #############################################
      csv = "LiPS-CSV,Ver1.10,線型計画法計算[LiPS #{t :lips}] 結果　(#{minmax}),\n"
      csv << "このファイルはUploadできます。\n"	
      csv << "最大化/最小化,#{minmax},,,#{t :operation}," << @opename[1..-1].join(",") << "\n"
      csv << ",,,,#{t :runtime}," << @time[1..-1].join(",") << "\n"
      csv << "#{t(:profit)},#{@profit},,,以上・以下,"
      csv << @gele[1..-1].map{|gl| gl == ">="  ? "以上" : "以下"}.join(",") << "\n"    
      csv << ",,,,実稼働," << @ope[1..-1].join(",") << "\n"    
      csv << ",,,,稼働率,"
      csv << (1..@opemax).map{|ope| 
        if @time[ope]==0.0 ; vv="" ; 
        else ; vv= sprintf("%4.1f%%",100 * ( @ope[ope]/@time[ope]))
        end
      }.join(",")
      csv << "\n"
      
      csv << "#{t(:pro_name)},#{t(:pro_gain)},#{t(:min)},#{t(:max)},#{t(:number)},#{t :coment}\n"
      (1..@promax).each{|pro| csv << @proname[pro] << ","
        #  product="pro#{pro}" ;gain = "gain#{pro}";min="min#{pro}";max="max#{pro}"
        csv << [:gain,:min,:max,:pro].map{|sym| 
          v=self.send(sym)[pro] ; vv = v==0.0 ? "" : v 
        }.join(",")
        csv << ","
        csv << (1..@opemax).map{|ope| v = @rate[pro][ope] ; vv = v==0.0 ? "" : v }.join(",")
        csv << "\n"
      }
    end
    fp=open(csvfile,"w")
    fp.print NKF.nkf("-s",csv)
    fp.close
  end

  A1=["LiPS-CSV","LiPS-CSV-H"]
  B1=["Ver1.00","Ver1.10"]
  D9D11=   [t(:operation),t(:runtime),"以上・以下"]

  def csv_upload(csvfile)

    begin
      #case csvfile.class
      #when ActionController::UploadedTempfile ;  infp = csvfile
      #when String                             ;  infp = open(csvfile)
      #end
      strs = NKF.nkf("-w",csvfile.read)
    rescue
      @errors.add_to_base("ファイルが指定されて居ません")
      return
    end
    if strs.size == 0
      @errors.add_to_base "ファイルが空です"
      return 
    elsif strs[0,10] =~ /[^ -~]/
      @errors.add_to_base "CSV形式ではないようです。もしくはLiPSの書式ではないようです。"
      return
    end
    rows = CSV.parse( strs)
    a1,b1 =rows.shift
    
    unless A1.include?(a1) and B1.include?(b1)
      @errors.add_to_base "LiPSの書式ではないようです"   
      return
    end
    # of = open("/tmp/LiPSupload_#{cgi.remote_user}.csv","w")
    # of.print strs
    # of.close
    f =rows.shift
    while f[0].nil?  or f[0] !~ /最大化\/最小/;  f =rows.shift ;    end
    @minmax  = (f[1] =~ /最小/) ? "minimize" : "maximize"
    rows.unshift(f)
    case a1
    when "LiPS-CSV"   ; cvs_up_vert(rows,b1,@error)
    when "LiPS-CSV-H" ; cvs_up_land(rows,b1,@error)
    end
  end

  def cvs_up_vert(rows,b1,error)
    ver = b1=="Ver1.00" ? 0 : (b1=="Ver1.10" ? 1 : -1)
    @vertical = "vertical"
    f =rows.shift
    idx = f.index{|s| s == t(:operation) }
    f = f[idx+1..-1]
    idx = f.index{|v| v.nil? or v == "" }
    f = f[0,idx] if idx
    if f.size > @opemax
      @errors.add_to_base "#{t :operation}数が多すぎます。#{@opemax+1}以上を切り捨てます"
      f = f[0,@opemax]
    end
    @opemax = f.size
    @opename[1..-1] = f
    
    #稼働時間
    f = rows.shift 
    until  f.shift == t(:runtime) ;end
    (1..@opemax).each{|ope|  f=f.map{|v| v.nil? ? "" : v}
      value = f.shift.to_f
      if value == 0.0
        error << "#{@opename[ope]}の#{t :runtime}が未入力です"
      else
        @time[ope] = value
      end
    }
    #以上・以下
    f = rows.shift 
    until  f.shift == "以上・以下" ;end
    (1..@opemax).each{|ope|
      value = f.shift
      if value =~ /^(以上)|(以下)$/
        @gele[ope]  = (value=="以上" ? ">=" : "<=")
      else
        @errors.add_to_base "#{@opename[ope]}の「以上・以下」が未入力です"
      end
    }
    
    #
    #while str !~ /^"?製品名"?,"?製品当り利益"?,"?最小製造数"?,"?最大製造数"?,/
#uts  [t(:pro_name),t(:pro_gain),t(:min),t(:max),t(:number)].join("|")
    while f[0,4] != [t(:pro_name),t(:pro_gain),t(:min),t(:max)];f = rows.shift ;end
    
    #csvs = []
    csvs = rows.delete_if{|f| f[0].nil? or f[0]==""}
    
    #while str=csv.gets ; break if $_ =~ /^("")?,/
    if csvs.size > @promax
      @errors.add_to_base "#{t(:product)}数が多すぎます。#{@promax+1}以降を切り捨てます"
      csvs = csvs[0,@promax]
    end
    @promax = csvs.size
    (1..@promax).each{|pro| 
      f =csvs.shift.map{|v| v.nil? ? "" : v}
      @proname[pro]  = f.shift
      @gain[pro] = f.shift.to_f
      if @gain[pro] == 0.0
        @errors.add_to_base  "#{@pronane[pro]}の利益が未入力"
      end
       @min[pro]  = f.shift.to_f
       @max[pro]  = f.shift.to_f
       @pro[pro]  = f.shift.to_f

      rate = nil
      (1..@opemax).each{|ope|
        @rate[pro][ope] = f.shift.to_f
        rate = true if  @rate[pro][ope] != 0.0
      }
      unless rate
        @errors.add_to_base "#{@proname[pro]}の「#{t :coment}」が一つも入って居ません"
      end 
      }  
  end

  def cvs_up_land(rows,b1,error)
    f =rows.shift
    @vertical = "landscape"
    idx = f.index{|s| s == t(:pro_name) }
puts  f.join("|")
    f = f[idx+1..-1]
    idx = f.index{|v| v.nil? or v == ""}
    f = f[0,idx] if idx
    if f.size > @promax
      @errors.add_to_base "#{t(:pro_name)}数が多すぎます。#{@promax+1}以上を切り捨てます"
      f = f[0,@promax]
    end
    @promax  = f.size
    @proname[1..-1] = f
    
    #製品当利益
    f = rows.shift.map{|v| v.nil? ? "" : v}
    until  f.shift == t(:pro_gain) ;end
    (1..@promax).each{|pro|
      @gain[pro] = f.shift.to_f
      if @gain[pro] == 0.0
        @errors.add_to_base "#{@proname[pro]}の#{t(:pro_gain)}が未入力です"
      end
    }
    #最小製造数
    f = rows.shift.map{|v| v.nil? ? "" : v}
    until  f.shift == t(:min) ;end
    (1..@promax).each{|pro|  @min[pro] = f.shift.to_f  }
    #最大製造数
    f = rows.shift.map{|v| v.nil? ? "" : v}
    until  f.shift == t(:max) ;end
    (1..@promax).each{|pro| @max[pro] = f.shift.to_f }

    #製造数
    f = rows.shift.map{|v| v.nil? ? "" : v}
    until  f.shift == t(:number) ;end
    (1..@promax).each{|pro| @pro[pro] = f.shift.to_f }

    while f[0,3] != [t(:operation),t(:runtime),"≦≧"];f = rows.shift ;end
    csvs = rows.delete_if{|f| f[0].nil? or f[0]==""}
    if csvs.size > @opemax
      @errors.add_to_base "#{t(:operation)}数が多すぎます。#{@opemax+1}以降を切り捨てます"
      csvs = csvs[0,@opemax]
    end
    @opemax = csvs.size
    (1..@opemax).each{|ope| 
      f =csvs.shift.map{|v| v.nil? ? "" : v}
      @opename[ope] = f.shift
      
      @time[ope]  = f.shift.to_f
      if @time[ope] == 0.0
        @errors.add_to_base "#{@opename[ope]}の#{t :runtime}が未入力です"
      end 
      
      gele = f.shift
      if gele =~ /^(以上)|(以下)$/
        @gele[ope] = (gele=="以上" ? ">=" : "<=")
      else
        @errors.add_to_base "#{@opename[ope]}の「以上・以下」が未入力です"
      end
      
      rate = nil
      f.shift; f.shift
      (1..@promax).each{|pro|
        @rate[pro][ope] =f.shift.to_f
        if @rate[pro][ope]  != 0.0
          rate = true
        end
      }
      unless rate
        @errors.add_to_base "#{@opename[ope]}の「#{t :comnt}」が一つも入って居ません"
      end 
    }
  end  # of cvs_up_land(rows)
end

class String
def to_float ;  self.blank? ? 0.0 : self.to_f ;end
end
class Nil
def to_float ;  0.0 ;end
end
__END__
c=HashWithIndifferentAccess.new
b=HashWithIndifferentAccess.new
v=HashWithIndifferentAccess.new
vv=HashWithIndifferentAccess.new
vv["1"]=2.1
vv["2"]=2.2
v["3"]=vv
b["1"]="FFF"
b["2"]="ggg"
c[:proname]=b
c[:rate]=v
l=Lips.new(c)

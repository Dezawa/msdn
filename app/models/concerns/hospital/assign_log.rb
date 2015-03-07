# -*- coding: utf-8 -*-
# 
module Hospital::AssignLog
  include Hospital::Const

  ############################################
  # logger への出力
  ###########################################

  def dbgout(msg,sw=(LogPuts|LogInfo))
    #puts msg         if sw & LogPuts
    if sw & LogInfo
      logger.info  msg 
    elsif sw & LogDebug
      logger.debug msg  
    end
  end

  def log_start_title
    logger.info "HOSPITAL ASSIGN START ON  部署 #{busho_id}, #{@month.strftime('%Y/%m')} "+Time.now.to_s +
      "########################################"
  end

  def log_newday_entrant(day)
    dbgout("HP ASSIGN #{day}日entry-#{@count}")
    dbgout("assign_by_re_entrant")
    dbgout dump("  HP ASSIGN ")
  end

  def assign_log(day,shift,nurces,line,patern=nil,msg="",sw=(LogPuts|LogInfo))
    dbgout("HP ASSIGN LOG (#{line}) #{day}:#{shift}" + (patern ? "(%4s)"%patern.to_s : "    ") +
           ' '*day + nurce_list(nurces) + " "*(34-day)+msg ,
           sw)
  end

  def entry_log(day,shift,line,need_nurces,short_roles,as_nurces,sw=(LogPuts|LogInfo))
    dbgout("HP ASSIGN(#{line})  #{day}:#{shift} [] [] ENTRY  必要看護師数 #{need_nurces}"+
           " 不足role["+short_roles.join(",")+ "] 可能看護師"+ nurce_list(as_nurces),
           sw
           )
  end



  ################################################
  #  繰り返しなどの統計u出力
  ################################################
  def log_stat(opt ={ })
    head = opt.delete(:head) || ""
    msg = "FINISHED #{Hospital::Busho.find(@busho_id).name} #{@month.strftime('%Y/%m')}月" +
      "   shift分再帰 %3d回, 評価%4d回 %5.1f秒 ON "%[@entrant_count,@loop_count,@fine-@start]+
      Time.now.strftime("%Y-%m-%d %H:%M:%S")+"\n"+
      " [実数/必要数]：リーダー #{leader_arrow}/#{leader_need}人日、"+
      "看護師 #{kangoshi_arrow}/#{kangoshi_need}人日" 
    msgstat0 = "#{head} STAT shift  評価 失敗 戻り" + @count_cause.keys.map{ |k| "%8s"%k}.join(" ") +"\n"
    msgstat1 = 
      @shifts123.map{|sft_str|
      "       %s    %4d %4d %4d"%[sft_str,@count_eval[sft_str],@count_fail[sft_str],@count_back[sft_str]] +
      @count_cause.keys.map{ |k| "%9d"%@count_cause[k][sft_str]}.join

    }
    msgmissing = @missing_roles.size == 0 ? "" :
      "\n   不足Role "+@missing_roles.to_a.
      map{ |id_shift,count| "  [%s] %d回"%[id_shift.join("-"),count]}.join(",") 
    # msgstat += @count_cause.keys.map{ |k| "%9d"%@count_cause[k][shift]}.join

    dbgout("#{head} #{msg}")
    dbgout(head+msgstat0+head+msgstat1.join("\n#{head}\n")+@count_fail.to_s + msgmissing)
    
    logout_stat "#{msg}\n" +msgstat0+msgstat1.join("\n") + msgmissing
  end

  def log_stat_result
    @fine = Time.now ; log_stat( ) 
    #if count == 0
    dbgout("HP ASSIGN (#{__LINE__})output to file #{ @basename + "%04d"%@count}")
    open( @basename + "%04d"%@count ,"w"){ |fp| fp.puts dump }
    dbgout("HP ASSIGN (#{__LINE__})output done")
    #end
    save
  end
  #######################################
  #  実行条件と処理時間の統計
  ########################################
  def statistics_log_title
    log_statistics("",:header => @assign_start_at.
                   strftime("%m/%d-%H:%M "+
                            "Timeout #{Hospital::Const::Timeout} "+
                            "List Min=#{Hospital::Const::LimitOfNurceCandidateList}"+
                            " 係数=#{Hospital::Const::Factor_of_safety_NurceCandidateList}")
                   )
  end


  def log_statistics(msg,opt={ })
    open( File.join( Rails.root,"tmp","hospital","log","statistics"),"a"){ |fp|
      if opt[:header] 
        fp.puts opt[:header] 
      else
        fp.puts "部署 #{busho_id} #{month.strftime('%Y/%m')} #{msg}"
      end
    }
  end

  ###########################
end

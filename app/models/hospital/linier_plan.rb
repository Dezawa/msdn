require 'pp'
class Hospital::LinierPlan

  def initialize(arg_busho_id,arg_month)
    @month = arg_month
    @busho_id = arg_busho_id
    @lastday=@month.end_of_month.day
    @assign = Hospital::Assign.new(@busho_id,@month)
    @roles = Hospital::Role.all
  end

  def lp_out(fp=$stdout)
    fp.puts "param n := #{@assign.nurces.size} ; /* 看護師数 */"
    fp.puts "param d := #{@lastday}      ; /* 月の日数 */"
    fp.puts "param s := #{Hospital::Role.all.size} ; /* 資格の数    */"
    fp.puts "param l := 5 ; /* 制限の数 */"
    fp.puts nurce_role
    fp.puts nurce_limit
    fp.puts daytype
    fp.puts daytype_need
  end

  def need
    "\n平土日祝、日準深,資格毎の必要人数\n" + 
      "param need := \n"+
      (1..2).map{|t| (1..3).map{|k| @roles.map{|role|
          need_patern = @assign.need_patern[t+1]
          "[#{t},#{k},#{role.id}] #{need_patern[t][role.id,k]}\n"
     }.join+";\n"
      }.join }.join
  end 

  def daytype_need
    "\n/* 平土日祝、日準深,資格毎の必要人数 */\n" + 
      "param need := \n"+
      (1..2).map{|t| 
          need_patern = @assign.need_patern[t-1]
      (1..3).map{|k| 
        @roles.map{|role|
          if need_patern[[role.id,k]]
            "[#{t},#{k},#{role.id}] #{need_patern[[role.id,k]][0]}\n" 
          else
            "[#{t},#{k},#{role.id}] 0\n" 
          end
     }.join
      }.join }.join+";\n"
  end
  def daytype
    "\n/* 各日が平日か土日祝日か */\n"+
      "param daytype :=\n" +
      (1..@lastday).map{|day| date = @month +(day-1).day
      what_day = (date.wday%6 == 0 || Holyday.find_by_day(date)) ? 2 : 1
      "%d %d\n"%[day,what_day]
    }.join+";\n"
  end

  def nurce_role
    i = 0
    "\n/* 看護師がもつ資格 */\n" + 
      "param role : #{(1..@roles.size).map{|s| s}.join(" ")} :=\n" +
      @assign.nurces.map{|nurce|
      i += 1
      roles= nurce.roles_by_id 
      "#{i} " +
      @roles.map{|role| roles[role.id] ? " 1" : " 0" }.join
    }.join("\n")+";\n"
  end
  def nurce_limit
    i=0
    "\n/* 看護師の勤務制限 */\n" + 
      "param limit : 1 2 3 4 5 :=\n" +
      @assign.nurces.map{|nurce|
      i += 1
      limits = nurce.limits
      "%d %d %d %d %d %d\n "%[i,
      limits.code0,limits.code1,limits.code2,limits.code3,limits.coden]
    }.join+";\n"
  end

  def date_need
    "\n各日の必要資格数\m" +
      "param need : " +
      (1..Hospital::Role.all.size).to_a.map{|i| i}.join(" ") +
      @assign.nurces.each_with_index{|nurce,i|
      "#{i+1} " 
    }.join+";\n"
  end
end

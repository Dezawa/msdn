# -*- coding: utf-8 -*-
class Hospital::MonthlyController < Hospital::Controller
 # extend Hospital::Const
  include Hospital::Const
  before_filter :set_instanse_variable

  def set_instanse_variable
    @Model= Hospital::Monthly
    @TYTLE = "希望登録"
    @Domain= @Model.name.underscore
    @TableEdit = true
    #@Edit = true
    #@Delete=true
    @labels= [HtmlText.new(:name,"役割")

             ]
    super
    @TYTLE_post_edit = @month.strftime('%Y年%m月')
    @basename = File.join( Rails.root,"tmp","hospital",
                          "Shift_%02d_%02d_"%[@current_busho_id,@month.month])
  end
  
  AssignCorrection = {}
  (1..6).each{|kinmukubun_id|
    AssignCorrection[kinmukubun_id] = 
    Hospital::Kinmucode.
    where(["kinmukubun_id = ? or kinmukubun_id = 7",kinmukubun_id]).
    pluck(:code,:id)
  }

  def hope_regist
    @must   = params[:must][:val].to_i rescue 1
    @assign = Hospital::Assign.new(@current_busho_id,@month)
    @nurces = @assign.nurces #Hospital::Nurce.all(:conditions@current_busho_id]=>["busho_id = ?",@current_busho_id])
    @TYTLE_post_edit = %w(弱 強)[@must]  + "　　"+@month.strftime('%Y年%m月')

  end

  def hope_update
    must = params[:must][:val].to_i
    must_offset = [1000,2000][must] 

    params[@Domain].each_pair{|nurce_id,day_columns|
      nurce=Hospital::Nurce.find(nurce_id.to_i)
      monthly=nurce.monthly(@month)
      day_columns.each_pair{|day_column,id| 
        if !id || !monthly[day_column]
          monthly[day_column] = 0 
        elsif monthly[day_column] == 0 || monthly[day_column]%1000 != id.to_i%1000
          monthly[day_column] = id.to_i + must_offset
        end
     }
      monthly.save
   }
   redirect_to :action => :show_assign
  end

  def show_result
    @no = params[:no]
    @assign = Hospital::Assign.new(@current_busho_id,@month)
    @files = Dir.glob(@basename+"[0-9][0-9][0-9][0-9]").sort 
    @assign.set_shifts_by_file(@basename+params[:no]) 
    @nurces =@assign.nurces
    @mult  = params[:mult]
    render :action => :show_assign 
  end

  def wait_assign
    @first  = Dir.glob(@basename+"0000")
logger.debug("WAIT_ASSIGN: @first=#{@first} ******************************")
    if @first.size > 0
      @wait  = nil
      redirect_to :action => :show_assign, :mult => "20"
    else
      render :text => ""
    end
    #render :text => ""
  end

  def assign_links
    @files = Dir.glob(@basename+"[0-9][0-9][0-9][0-9]").sort 
    @fine  = Dir.glob(@basename+"FINE")
    delayed_job = delayed_jobs[0]
    @stop_time = delayed_job ? delayed_job.run_at + Hospital::Const::Timeout + 
        Hospital::Const::TimeoutMult : Time.now
  end
  
  def show_assign
    #@nurces = Hospital::Nurce.all(:conditions=>["busho_id = ?",@current_busho_id])
    @assign = Hospital::Assign.new(@current_busho_id,@month)
    @nurces =@assign.nurces
    @files = Dir.glob(@basename+"[0-9][0-9][0-9][0-9]").sort 
    @mult  = params[:mult]
    @wait  = params[:wait]
    @errors = params[:error]
  end

  def delayed_jobs
    condition = "handler LIKE '%Hospital::Assign\nmethod: :create_assign\nargs: \n- #{@current_busho_id}\n- #{@month.strftime('%Y-%m-%d')}\n- 2\n%'"
    Delayed::Job.all(:conditions => condition)
  end

  def assign
      #ret=Hospital::Assign.delay(:attempts => 1).create_assign(@current_busho_id,@month,2)
      first_day_combination,initial_state = Hospital::Assign.create_assign(@current_busho_id,@month,SingleSolution)
      HospitalBackendJob.new(@current_busho_id,@month,first_day_combination,initial_state)
      redirect_to :action => :show_assign,:mult => "20",:no => "0000"
  end


  def clear_assign
    @assign=Hospital::Assign.new(@current_busho_id,@month)
    condition = "handler LIKE '%Hospital::Assign\nmethod: :create_assign\nargs: \n- #{@current_busho_id}\n- #{@month.strftime('%Y-%m-%d')}\n- 2\n%'"
    delayed_jobs = [] #Delayed::Job.all(:conditions => condition)

    if delayed_jobs.size ==0
      @assign.clear_assign_all.save
      @nurces = @assign.nurces
      redirect_to :action => :show_assign
      #render :action => :show_assign
    else
      redirect_to( :action => :show_assign,:mult => "20",
                   :error => "実行中です。#{(delayed_jobs.first.run_at+5.minute).strftime('%H:%M')}ころまでお待ち下さい"
                   )      
    end
  end

  def error_disp
    @error_days,@error_nurces = Hospital::Assign.new(@current_busho_id,@month).error_check
    render :layout => "hospital_error_disp"
  end
  def set_busho_month
    set_busho_month_sub
    redirect_to :action => :show_assign
  end    
end

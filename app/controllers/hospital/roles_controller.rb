# -*- coding: utf-8 -*-
class Hospital::RolesController < Hospital::Controller
  before_filter :set_instanse_variable

  def set_instanse_variable
    @Model= Hospital::Role
    @TYTLE = "役割・グループ登録"
    @Domain= @Model.name.underscore
    @TableEdit = [[:add_edit_buttoms],
                  ["　　　"],
                  [:form,:show_assign,"所属メンバー"]]
    @Edit = true
    @Delete=true
    @labels= [HtmlText.new(:name,"役割"),
              HtmlSelect.new(:bunrui,"分類",
                             :correction => [["職位",1],["職種",2],["勤務区分",3],["資格",4]]),
              HtmlCheck.new(:need,"要否",:help => "Hospital#need")
             ]
    @on_cell_edit = true
    super
  end

  AssignLabel =
    [
     HtmlText.new(:code0,"公休",:size => 2),
     HtmlText.new(:code1,"日勤",:size => 2),
     HtmlText.new(:code2,"準夜",:size => 2),
     HtmlText.new(:code3,"深夜",:size => 2),
     HtmlText.new(:coden,"年休",:size => 2),
     HtmlText.new(:night_total,"夜勤計",:size => 2),
     HtmlText.new(:kinmu_total,"勤務計",:size => 2),
     ]

  def show_assign
    $HP_DEF =  Hospital::Define.create
    @roles  = Hospital::Role.all(:conditions => "bunrui <> 3")
    @labels = AssignLabel 
    @nurces = Hospital::Nurce.by_busho(@current_busho_id)
    @TableEdit = [[:form,:assign,"編集"],
                  ["　　　"],
                  [:form,:set_busho,"部署変更",:input_busho]]
    @warn = Hospital::Limit.enough?(@current_busho,@month).first
  end
  def dddset_busho
    super
    redirect_to :action => :show_assign
  end

  def assign
    @roles=Hospital::Role.all
    @labels = AssignLabel 
    @nurces = Hospital::Nurce.by_busho(@current_busho_id)
  end
  def update_assign
    params[@Domain].each_pair{|nurce_id,roles|
      nurce = Hospital::Nurce.find nurce_id
      limit = roles.delete(:limit)
      nurce.create_limit(Hospital::Nurce::LimitDefault) unless nurce.limit
      if limit 
        nurce.limit.update_attributes(limit) 
        nurce.save
      end
      roles.each_pair{|role_id,assigned|
        logger.debug("RoleUpdateAssign Nurce #{nurce_id},role #{role_id}=>#{nurce.role_id?(role_id)},#{assigned}")
        case [!!nurce.role_id?(role_id.to_i),assigned]
        when [false,"1"] ; nurce.hospital_roles << Hospital::Role.find(role_id)
        when [true ,"0"] ; nurce.hospital_roles.delete(Hospital::Role.find(role_id))
        end  # [true,"1"],[false,"0"] ; # do notheig
      }
      
    }
    redirect_to :action => :show_assign
  end

  def index
    find_and
  end

end

# -*- coding: utf-8 -*-
class Hospital::RolesController < Hospital::Controller
  before_filter :set_instanse_variable

  def set_instanse_variable
    @Model= Hospital::Role
    @TYTLE = "役割・グループ登録"
    @Domain= @Model.name.underscore
    @TableEdit = [[:add_edit_buttoms],
                  ["　　　"],
                  [:form,:show_assign,"所属メンバー",:method => :get]]
    @Edit = true
    @Delete=true
    @labels= [HtmlText.new(:name,"役割"),
              HtmlSelect.new(:bunrui,"分類",:correction => Hospital::Role::Bunrui),
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
    @roles_by_bunrui = Hospital::Role.order(:id).group_by{ |role| role.bunrui}
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
    @roles_by_bunrui = Hospital::Role.order(:id).group_by{ |role| role.bunrui}
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
      Hospital::Role.shikaku.map{ |role_name,role_id|
        logger.debug("Hospital::Role UPDATE_ASSIGN role_id=#{role_id} nurce.role_id?(role_id)=#{nurce.role_id?(role_id)},roles[role_id.to_s]=#{roles[role_id.to_s]}")
        case [!!nurce.role_id?(role_id),roles[role_id.to_s]=="1"]
        when [true ,false] ; nurce.remove_role(role_id)
        when [false,true] ; nurce.add_role(role_id)
        end  # [true,"1"],[false,"0"] ; # do notheig
      }.compact.size > 0      
    }
    redirect_to :action => :show_assign
  end

  def index ;    find_and ;  end

  def set_busho
    set_busho_sub
    redirect_to :action => :index
  end
end

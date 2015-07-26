class TopController < ApplicationController
  #before_filter :authenticate_user! , :except => :linier_plan_general
  skip_before_action :verify_authenticity_token

  def msdn
  end

  #def 
end

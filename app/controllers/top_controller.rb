class TopController < ApplicationController
  #before_filter :authenticate_user! , :except => :linier_plan_general
  skip_before_filter :verify_authenticity_token

  def msdn
  end

  #def 
end

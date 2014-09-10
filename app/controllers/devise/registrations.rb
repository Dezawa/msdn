class Devise::RegistrationsController  < ApplicationController

  def create
    @user = User.new(permit_attr)
    success = @user && @user.save
    logger.debug("UserCreate success? #{success}")
    #logger.debug("UsetCreate #{@user.errors.on(:email)}")
    if success && @user.errors.empty?
        redirect_to :action => :index
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
    @arrowed_options = @user.user_options.map(&:id) || []
      render :action => 'new'
    end
  end #of create

end

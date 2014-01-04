# controller_macros.rb
module ControllerMacros
  def login_user(username)
    #before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in User.find_by(username: username)
    #end
  end
end

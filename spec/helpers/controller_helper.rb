include Devise::TestHelpers

 def login_as(username)
    @user = User.find_by(username: username)
    sign_in :user,@user
 end

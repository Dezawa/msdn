include Devise::TestHelpers

 def login_as(username)
    @user = User.find_by(username: username)
    sign_in :user,@user
 end

 TTT = [true]*3
 TTF=[true, true,false]
 TFF=[true,false,false]
 FFF=[false]*3
 NNN=[nil]*3

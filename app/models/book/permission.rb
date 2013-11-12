class Book::Permission < ActiveRecord::Base
  set_table_name 'book_permissions'
  belongs_to     :user
  EDIT = 2
  SHOW = 1
  NON  = 0
  Permission = %w(権限なし 参照のみ 編集可能)
  
  def validate
    set_user
    errors.add_to_base("協働ユーザ #{login}は未登録です") if !login.blank? && user_id.blank?
    errors.add_to_base("協働ユーザ が未入力です") if login.blank?
    errors.add_to_base("協働ユーザ に自分自身を登録できません") if login == owner
    errors.add_to_base("協働ユーザ は既に登録されています") if login_dupe?
  end
  
  def self.arrowed_owner_and_permission(login)
    ret = find(:all,:conditions=>["login = ? and permission > ? ",login,NON]).
      map{|bu| [bu.permission,bu.owner,bu.user_id ? bu.user.name : ""]}.
      sort{|a,b| b.first <=> a.first }
    #ret.size > 0 ? ret : nil
  end
  
  def self.arrowed_owner(login)
    ret = find(:all,:conditions=>["login = ? and permission > ?",login,NON]).
      sort{|a,b|  (b.permission <=> a.permission)*2 + (a.login <=> b.login)}
  end

  def self.create_myself(user)
    self.new(:login => user.login,:owner => user.login,:user_id => user.id,
             :permission => EDIT
             )
  end

  def self.create_nobody
    self.new(:login => "nobody",:owner => "nobody",:user_id => nil,:permission => NON )
  end

  def set_user
    self.user = User.find_by_login(login)
  end
  
  def owner_name
    User.find_by_login(owner).name || owner
  end

  def permission_string
    Permission[permission]
  end

  def owner_permission
    [owner,permission_string]
  end

  def login_dupe?
    objects = self.class.all(:conditions => ["not id = ? and login = ? and owner = ?",
                                             id,login,owner]).size > 0
  end
end

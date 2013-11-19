# -*- coding: utf-8 -*-

# restful-authentication の User に幾つか追加した。
# 追加したcolumn
# lipscsvio  :: LiPS の CSV 入出力が許されるか否か
# lipssizeoption  :: LiPS の最大モデルサイズ変更が許されるか否か
# lipssizepro  :: LiPS の製品数の最大
# lipssizeope  :: LiPS の工程数の最大
# lipslabelcode  :: LiPSのラベルのllocal 通常(default)では 製品、工程 だが、
## これをI18Nで変更可能にしている。宇部病院向けの試作。
# lipsoptlink  :: LiPSの結果を他のアプリにつなげる場合のリンク先。ウベボード用に作成。
##    lips_helper の method 名を書く。このmethodは link_to の実行結果を返す。
##    LipsHelper#to_ube_product 参照
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :user_options

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  #validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  #validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  #validates_uniqueness_of   :email
  #validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 7..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  #attr_accessible :login, :email, :name, :password, :password_confirmation,
  #:lipscsvio ,:lipssizeoption ,:lipssizepro ,:lipssizeope ,:lipslabelcode ,:lipsoptlink



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def password_required?
    encrypted_password.blank? || !password.blank?
  end

  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def option?(option_name)
    user_options.map(&:authorized).include?(option_name)
  end
  
end

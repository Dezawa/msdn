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
         :recoverable, :rememberable, :trackable, :validatable, 
         :encryptable, :encryptor => :restful_authentication_sha1

  has_and_belongs_to_many :user_options

  validates_presence_of     :username
  validates_length_of       :username,    :within => 3..40
  validates_uniqueness_of   :username
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  #validates_length_of       :email,    :within => 6..100 #r@a.wk
  #validates_uniqueness_of   :email
  #validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 7..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  
  def self.add_keys_for_parmit 
    [ :email, :name ]
  end

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

  def self.ddauthenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by(login: login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login ; username ;end
  def encrypted_password ;  crypted_password ;end
  def password_salt      ;  salt ;end
  def password_salt=(pswd_salt) ; self.salt = pswd_salt ;end
  def encrypted_password=(pass) ;self.crypted_password=pass ;end

  def login=(value)
    write_attribute :username, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def option?(option_name)
    user_options.map(&:authorized).include?(option_name)
  end
  
end

module Devise
  module Strategies
    # Default strategy for signing in a user, based on their email and password in the database.
    class DatabaseAuthenticatable < Authenticatable
delegate :logger, :to=>"ActiveRecord::Base"
      def authenticate!
        resource  = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
        encrypted = false
logger.debug("DatabaseAuthenticatable: #{resource}")
        if validate(resource){ encrypted = true; resource.valid_password?(password) }
          resource.after_database_authentication
          success!(resource)
        end

        mapping.to.new.password = password if !encrypted && Devise.paranoid
        fail(:not_found_in_database) unless resource
      end
    end
  end
end
class ActiveRecord::Base

  #self.table_name = 'book_mains'
  def self.table_name
    unless defined?(@table_name)
      if /::/ =~ self.name
        @table_name = self.name.gsub(/::/,"_").underscore.pluralize
      else
        reset_table_name
      end
    end 
    @table_name
  end
end

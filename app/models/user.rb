class User < ActiveRecord::Base
  devise :two_factor_authenticatable,
         :otp_secret_encryption_key => ENV['2FA_KEY']

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
         
  extend FriendlyId
  friendly_id :username, use: :slugged

  # Setup accessible (or protected) attributes for your model
#  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  # attr_accessible :title, :body
  
  has_many :items, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :entries, through: :items
  
  has_many :pages, dependent: :destroy

  validates_uniqueness_of :username  
  validates_presence_of :password_confirmation, on: :create
  validates_presence_of :username

end

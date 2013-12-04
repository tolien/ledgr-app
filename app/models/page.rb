class Page < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  acts_as_list
  
  attr_accessible :title
  
  default_scope order ("position ASC")
  
  belongs_to :user
  has_many :displays
  
  validates_presence_of :user
  validates_numericality_of :position, only_integer: true, greater_than_or_equal_to: 0
end

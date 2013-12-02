class Page < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  attr_accessible :title
  
  belongs_to :user
  
  validates_presence_of :user
  validates_numericality_of :position, only_integer: true, greater_than_or_equal_to: 0
end

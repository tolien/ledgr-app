class Page < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  attr_accessible :title
  
  belongs_to :user
  
  validates_presence_of :user
end

class Page < ActiveRecord::Base
  attr_accessible :title
  
  belongs_to :user
  
  validates_presence_of :user
end

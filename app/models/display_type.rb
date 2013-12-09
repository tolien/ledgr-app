class DisplayType < ActiveRecord::Base
  attr_accessible :description, :name, :type
  
  has_many :displays
  
  validates_length_of :name, minimum: 1
end

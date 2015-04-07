class DisplayType < ActiveRecord::Base
#  attr_accessible :description, :name, :type
  
  has_many :displays
end

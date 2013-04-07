class Entry < ActiveRecord::Base
  attr_accessible :datetime, :quantity, :item_id, :user_id
  
  validates :quantity, numericality: true
  validates_presence_of :item
  validates_datetime :datetime
  validates_presence_of :user
  
  belongs_to :item
  belongs_to :user
end

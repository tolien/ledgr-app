class Entry < ActiveRecord::Base
  attr_accessible :datetime, :quantity, :item_id, :user_id
  
  validates :quantity, numericality: true
  validates_presence_of :item
  validates_datetime :datetime
  
  belongs_to :item
end

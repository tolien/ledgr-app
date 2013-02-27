class Entry < ActiveRecord::Base
  attr_accessible :datetime, :quantity, :item_id
  
  belongs_to :item
end

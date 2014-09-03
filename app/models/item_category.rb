class ItemCategory < ActiveRecord::Base
  attr_accessible :category_id, :item_id
  
  validates :item_id, :category_id, presence: true
  validates :item_id, uniqueness: { scope: :category_id, message: "can be a member of a category only once" }
  
  belongs_to :item
  belongs_to :category
  
end

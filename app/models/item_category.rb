class ItemCategory < ActiveRecord::Base
  attr_accessible :category_id, :item_id
  
  validates :item_id, :category_id, presence: true
  validates :item_id, uniqueness: { scope: :category_id, message: "can be a member of a category only once" }
#  validate :name_is_unique_in_categories
  
  belongs_to :item
  belongs_to :category
  
  def name_is_unique_in_categories
    Rails.logger.debug("Validating uniqueness for " + item.name)
    item.categories.each do |category|
      Rails.logger.debug("Checking " + category.name)
      category.items.each do |item|
        Rails.logger.debug("item " + item.id.to_s + ", " + item.name)
        if item.name.eql?(self.item.name) and not item.id.eql?(self.item.id)
          errors.add(:item_categories, "item must be unique in the category")
        end
      end
    end
  end
end

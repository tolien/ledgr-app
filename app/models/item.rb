class Item < ActiveRecord::Base
  attr_accessible :name, :category_ids
  
  validates :name, presence: true
  validate :name_is_unique_in_categories, on: :create
  
  belongs_to :users
  has_many :categories
  has_many :entries
  has_and_belongs_to_many :categories, join_table: 'item_categories'
  
  def name_is_unique_in_categories
    categories.each do |category|
      category.items.each do |item|
        if item.name.eql?(self.name)
          errors.add(:name, "must be unique in the category")
        end
      end
    end  
  end
end

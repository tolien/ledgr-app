class Category < ActiveRecord::Base
  attr_accessible :name, :user_id
  
  has_many :item_categories, dependent: :destroy
  has_many :items, through: :item_categories
  
  belongs_to :user
  
  validates_presence_of :name, :user
  validates :name, uniqueness: { scope: :user_id }
end

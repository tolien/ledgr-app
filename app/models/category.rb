class Category < ActiveRecord::Base
#  attr_accessible :name, :user_id
  
  has_many :item_categories, dependent: :destroy
  has_many :items, through: :item_categories
  
  has_many :display_categories, dependent: :destroy
  has_many :displays, through: :display_categories
  
  belongs_to :user
  
  validates_presence_of :name, :user
  validates_uniqueness_of :name, scope: :user_id, case_sensitive: :false
  
  default_scope { order('name ASC') }
  
  def entry_count
    total = 0
    if !items.empty?
      items.each do |item|
        total = total + item.entries.size
      end
    end
    total
  end
end

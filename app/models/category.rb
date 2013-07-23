class Category < ActiveRecord::Base
  attr_accessible :name, :user_id
  
  has_many :item_categories, dependent: :destroy
  has_many :items, through: :item_categories
  
  has_many :display_categories, dependent: :destroy
  has_many :displays, through: :display_categories
  
  belongs_to :user
  
  validates_presence_of :name, :user
  validates :name, uniqueness: { scope: :user_id }
  
  default_scope { order('name ASC') }
  
  def self.find_or_create_by_user_and_name(user, name)
  logger.debug('user_id: ' + user.id.to_s)
  logger.debug('category name: ' + name)
  
    category = Category.find_by_name_and_user_id(name, user.id)
    
    if category.nil?
      logger.debug('creating new category')
      category = Category.create(name: name, user_id: user.id)
    end
    category
  end
  
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

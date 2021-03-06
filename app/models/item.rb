class Item < ActiveRecord::Base
  #  attr_accessible :name, :user_id, :category_ids

  belongs_to :user
  has_many :entries, dependent: :delete_all

  has_many :item_categories, dependent: :destroy
  has_many :categories, through: :item_categories

  validates_associated :item_categories
  validates_presence_of :user, :name

  default_scope { order("name ASC") }

  def add_category(category)
    if !categories.include? category
      begin
        categories << category
      end
    end
  end

  def self.find_or_create_by_user_and_name(user, name)
    logger.debug("user_id: " + user.id.to_s)
    logger.debug("item name: " + name)

    item = Item.find_by_name_and_user_id(name, user.id)

    if item.nil?
      logger.debug("creating new item")
      item = Item.create(name: name, user_id: user.id)
    end
    item
  end

  def total
    self.entries.sum(:quantity).to_f
  end
end

class Category < ActiveRecord::Base
  attr_accessible :name
  
  has_and_belongs_to_many :items, join_table: 'item_categories'
  belongs_to :users
end

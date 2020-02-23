class DisplayCategory < ActiveRecord::Base
  #  attr_accessible :category_id, :display_id

  validates_presence_of :category_id
  validates_presence_of :display_id

  belongs_to :category
  belongs_to :display
end

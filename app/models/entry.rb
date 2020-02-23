class Entry < ActiveRecord::Base
  validates :quantity, numericality: true
  validates_presence_of :item
  validates_datetime :datetime
  validates_associated :item

  belongs_to :item, counter_cache: true

  default_scope { order("datetime DESC") }
end

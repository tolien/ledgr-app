class DisplayType < ActiveRecord::Base
  attr_accessible :description, :name
  
  has_many :displays, dependent: :destroy
  
  validates_length_of :name, minimum: 1
  
  def get_data_for(display)
    # need to sort out summing by {item, category}
    item_list = Item.unscoped.joins(:entries, :categories)
    .where(categories: {id: display.categories})
    .select("items.id, items.name, sum(entries.quantity) AS sum")
  end
end

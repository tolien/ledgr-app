class DisplayType < ActiveRecord::Base
#  attr_accessible :description, :name
  
  has_many :displays, dependent: :destroy
  
  validates_length_of :name, minimum: 1
	validates_uniqueness_of :type
  
  def get_data_for(display)
    # need to sort out summing by {item, category}
    item_list = Item.unscoped.joins(:entries, :categories)
    .where(categories: {id: display.categories})
#    .select("items.id, items.name, sum(entries.quantity) AS sum")
    
    if display.start_date
      start_date = display.start_date
    elsif display.start_days_from_now
      start_date = DateTime.now.at_beginning_of_day - display.start_days_from_now.days
    end

    unless start_date.nil?
      item_list = item_list.where('entries.datetime >= ?', start_date)
    end
        
    unless display.end_date.nil?
      item_list = item_list.where('entries.datetime <= ?', display.end_date)
    end

    item_list
  end
end

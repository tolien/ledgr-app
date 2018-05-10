class Display < ActiveRecord::Base
#  attr_accessible :end_date, :start_date, :title, :display_type_id
  
  belongs_to :display_type
  belongs_to :page
  
  acts_as_list add_new_at: :bottom
  
  has_many :display_categories, dependent: :destroy
  has_many :categories, through: :display_categories
  
  validates_presence_of :display_type
  validates_presence_of :page
  validates_numericality_of :position, allow_nil: true, only_integer: true, greater_than_or_equal_to: 0

  def get_data
    unless self.categories.empty?
      self.display_type.get_data_for(self)
    else    
        Item.none
    end
  end

  def get_item_list
    unless self.categories.empty?
      item_list = Item.unscoped.joins(:entries, :categories)
        .where(categories: {id: self.categories})
        
    if self.start_date
      start_date = self.start_date
    elsif self.start_days_from_now
      start_date = DateTime.now.utc.at_beginning_of_day - self.start_days_from_now.days
    end

    unless start_date.nil?
      item_list = item_list.where('entries.datetime >= ?', start_date)
    end
        
    unless self.end_date.nil?
      item_list = item_list.where('entries.datetime <= ?', self.end_date)
    end


    item_list = item_list.select("items.id, items.name, sum(entries.quantity) AS sum")
    item_list = item_list.group(:id, :name)
    item_list = item_list.reorder('sum DESC')
    item_list.to_a
    
    end
  end
end

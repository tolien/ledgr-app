class Display < ActiveRecord::Base
#  attr_accessible :end_date, :start_date, :title, :display_type_id
  
  belongs_to :display_type
  belongs_to :page
  
  has_many :display_categories, dependent: :destroy
  has_many :categories, through: :display_categories
  
  validates_presence_of :display_type
  validates_presence_of :page
  
  def get_data
    unless self.categories.empty?
      self.display_type.get_data_for(self)
    else    
        Item.none
    end
  end
end

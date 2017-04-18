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
end

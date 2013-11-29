class Display < ActiveRecord::Base
  attr_accessible :end_date, :start_date, :title, :display_type_id
  
  belongs_to :display_type
  
  has_many :display_category, dependent: :destroy
  has_many :categories, through: :display_category
  
  validates_presence_of :display_type
end

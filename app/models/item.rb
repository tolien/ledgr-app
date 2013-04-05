class Item < ActiveRecord::Base
  attr_accessible :name, :user_id
  
  validates :name, presence: true, uniqueness: true
  
  belongs_to :user
  has_many :entries
  
  has_many :item_categories, dependent: :destroy
  has_many :categories, through: :item_categories

  def add_category(category)
    begin
      categories << category      
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      errors[:categories] << "Item can only be a member of a category once"
    end
  end  

end

class Page < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged

  acts_as_list

  default_scope { order "position ASC" }

  belongs_to :user
  has_many :displays, -> { order(position: :asc) }, dependent: :destroy

  validates_presence_of :user
  validates_numericality_of :position, allow_nil: true, only_integer: true, greater_than_or_equal_to: 0

  def should_show_for?(user)
    if self.is_private
      if user.nil?
        false
      else
        self.user.eql? user
      end
    else
      true
    end
  end
end

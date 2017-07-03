require 'test_helper'
    require 'action_view'
    include ActionView::Helpers::DateHelper

class PageTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
  end
  
  test "a page must be owned by a user" do
    page = FactoryGirl.build(:page)
    assert page.invalid?
    assert page.errors[:user].include?("can't be blank")
  end
  
  test "page position must be an integer" do
    page = FactoryGirl.build(:owned_page)
        
    page.position = "I'm a little teapot"
    assert_not page.valid?
    assert_not page.errors[:position].empty?
    
    # this is a strange one - before validation, acts_as_list resets the position
    # to list top: 1, by default
    page.position = -1
    assert page.valid?
    assert_equal 1, page.position
    assert page.errors[:position].empty?
    
    page.position = 0
    page.valid?
    assert page.valid?
    assert page.errors[:position].empty?
    
    page.position = 100
    assert page.valid?
    assert page.errors[:position].empty?
        
    page.save
    assert_not_nil page.position
  end
  
  test "pages are loaded in the correct order" do
    page_list = []
    
    10.times do
      page = FactoryGirl.build(:page)
      page.user = @user
      page.move_to_top
      page.save!
      page_list.insert(0, page.title)
    end

    assert_equal 10, @user.pages.size
    @user.pages.each do |page|
      title = page_list.shift
      assert_equal title, page.title
    end
  end
  
  test "distance_of_time_in_words works" do
    assert_equal 2, 7200 / 1.hour
    assert_equal 1, 3600 / 1.hour
    assert_equal "1 hour", distance_of_time_in_words(Time.now - 1.hour, Time.now)
#    assert_equal 60, 5.minutes % 2.minutes
#    assert_instance_of Numeric, 5.minutes % 2.minutes
#    assert_equal 3600, 5.hours % 2.hours
#    assert_instance_of Numeric, 5.hours % 2.hours
#    assert_equal 1, 5.seconds % 2.seconds
#    assert_instance_of Numeric, 5.seconds % 2.seconds
    
    scalar = ActiveSupport::Duration::Scalar.new(10 * 24 * 60 * 60)
#    assert_instance_of Float, (scalar / 5.days)
#    assert_equal 2, (scalar / 5.days)
    
    scalar = ActiveSupport::Duration::Scalar.new(12 * 60 * 60)
#    assert_instance_of Float, (scalar / 1.days)
#    assert_equal 0.5, (scalar / 1.days)
  end
end

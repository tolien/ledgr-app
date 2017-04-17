require 'test_helper'

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
      page.save!
      page_list.append(page.title)
    end
    
    page_list.reverse
    @user.pages.each do |page|
      title = page_list.pop
      assert_equal title, page.title
    end
  end
end

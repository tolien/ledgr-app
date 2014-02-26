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
  
  test "page position must be set, integral and >=0" do
    page = FactoryGirl.build(:page)
    
    page.position = 0
    page.valid?
    assert page.errors[:position].empty?
    
    page.position = 100
    page.valid?
    assert page.errors[:position].empty?
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

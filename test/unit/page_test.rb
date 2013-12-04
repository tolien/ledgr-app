require 'test_helper'

class PageTest < ActiveSupport::TestCase
  
  test "a page must be owned by a user" do
    page = FactoryGirl.build(:page)
    assert page.invalid?
    assert page.errors[:user].include?("can't be blank")
  end
  
  test "page position must be set, integral and >=0" do
    page = FactoryGirl.build(:page)
    assert page.invalid?
    assert page.errors[:position].include?("is not a number")
    
    page.position = "wibble"
    assert page.invalid?
    assert page.errors[:position].include?("is not a number")
    
    page.position = -1
    assert page.invalid?
    assert page.errors[:position].include?("must be greater than or equal to 0")
    
    page.position = 0
    page.valid?
    assert page.errors[:position].empty?
    
    page.position = 100
    page.valid?
    assert page.errors[:position].empty?
  end
end

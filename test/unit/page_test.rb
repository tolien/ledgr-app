require 'test_helper'

class PageTest < ActiveSupport::TestCase
  
  test "a page must be owned by a user" do
    page = Page.create
    assert page.invalid?
    assert page.errors[:user].include?("can't be blank")
  end
  
  test "page position must be set, integral and >=0" do
    page = Page.create
    assert page.invalid?
    assert_not_same 0, page.errors[:position].size
    page.position = "wibble"
    
    assert page.invalid?
    assert_not_same 0, page.errors[:position].size
  end
end

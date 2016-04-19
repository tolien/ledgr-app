require 'test_helper'

class DisplayTest < ActiveSupport::TestCase
  setup do
    @display_type = FactoryGirl.build(:display_type)
    @page = FactoryGirl.build(:page)
  end
  
  test "a Display must be associated with a display type and page" do
    display = Display.create
    assert display.invalid?
    
    assert display.errors[:display_type].include? "can't be blank"
    assert display.errors[:page].include? "can't be blank"
    
    display.display_type = @display_type
    display.page = @page
    
    assert display.valid?
  end
end

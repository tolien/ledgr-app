require 'test_helper'

class DisplayTest < ActiveSupport::TestCase
  setup do
    @display_type = DisplayType.create
    @page = FactoryGirl.build(:page)
  end
  
  test "a Display must be associated with a display type and page" do
    display = Display.create
    assert display.invalid?
    
    
    display.display_type = @display_type
    display.page = @page
    
    assert display.valid?
  end
end

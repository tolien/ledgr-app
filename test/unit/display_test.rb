require 'test_helper'

class DisplayTest < ActiveSupport::TestCase
  setup do
    @display_type = FactoryGirl.build(:display_type)
    @page = FactoryGirl.build(:owned_page)
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
  
  test "displays are loaded in the correct order" do
    display_list = []
    
    @page.save!
    assert_not_nil @page
    assert_not_nil @page.id
    
    # display.display_type = @display_type
    
    @display_type.save
    display = FactoryGirl.build(:display, page: @page, display_type: @display_type)
    assert display.valid?
    
    10.times do
      display = display.dup
      display.position = nil

      display.save!
      display_list.append(display.id)
    end
    
    moved = @page.displays.first
    moved.move_to_bottom
    display_list.append(display_list.shift)
    display_list.reverse!
    
    assert_equal 10, @page.displays.count
    @page.displays.each do |display|
      id = display_list.pop
      assert_not_nil id
      assert_equal id, display.id
    end
  end
  
end

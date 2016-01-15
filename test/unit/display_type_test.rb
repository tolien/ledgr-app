require 'test_helper'

class DisplayTypeTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @type = FactoryGirl.create(:display_type)
    @page = FactoryGirl.build(:page)
    @page.user = @user
    @page.save!
    
    5.times do
      display = FactoryGirl.build(:display)
      display.page = @page
      display.display_type = @type
      display.save!
    end    
        
  end
  
  test "destroying a display type destroys its dependent displays" do
    # assert that there are displays beforehand, or this test is pointless
    assert !Display.where('display_type_id = ?', @type.id).empty?
    @type.destroy
    assert Display.where('display_type_id = ?', @type.id).empty?
  end
  
    test "start date constraints" do
    category = FactoryGirl.create(:category, user: @user)
    display = @page.displays.first
    display.categories << category
    display.start_date = 1.days.ago

    item = FactoryGirl.create(:item, user: @user)
    category.items << item
    
    entry = FactoryGirl.create(:entry, item: item, datetime: 5.days.ago)
    
    result = display.get_data
    assert_nil result

    display.start_date = 20.days.ago
    display.save!
    
    entry.reload
    result = display.get_data
    assert_equal entry.datetime.to_time, result
    
  end
end

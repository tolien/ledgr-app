require 'test_helper'

class TimeSinceLastEntryTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @page = FactoryGirl.create(:page, user: @user)
    display_type = DisplayTypes::TimeSinceLastEntry.new
    display_type.name = 'blah'
    display_type.save!
    @display = FactoryGirl.create(:display, display_type: display_type, page: @page)
    @category1 = FactoryGirl.create(:category, user: @user)
    @category2 = FactoryGirl.create(:category, user: @user)
  end
  
  test "if there are no categories should return nil" do
    assert_nil @display.get_data
  end
  
  test "if categories have no items should return nil" do
    @display.categories << @category1
    @display.save!
    
    assert_nil @display.get_data
  end
  
  test "if items have no entries should return nil" do
    @display.categories << @category1
    @display.save!
    
    item = FactoryGirl.build(:item, user: @user)
    @category1.items << item
    
    assert_nil @display.get_data
  end
  
  test "returns correct time" do
    @display.categories << @category1
    
    item = FactoryGirl.create(:item, user: @user)
    @category1.items << item
    
    entry = FactoryGirl.create(:entry, item: item, datetime: 5.days.ago)
    
    result = @display.get_data
    entry.reload
    assert_not_nil result
    assert_equal entry.datetime.to_time, result
  end
end

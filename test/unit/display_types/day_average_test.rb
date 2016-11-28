require 'test_helper'

class DayAverageTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @page = FactoryGirl.create(:page, user: @user)
    display_type = DisplayTypes::DayAverage.first
    if display_type.nil?
      display_type = DisplayTypes::DayAverage.new
      display_type.name = 'Entries Per Day'
      display_type.save!
    end
    @display = FactoryGirl.create(:display, display_type: display_type, page: @page)
    @category1 = FactoryGirl.create(:category, user: @user)
    @category2 = FactoryGirl.create(:category, user: @user)
  end

  test "if there are no categories should return empty list" do
    assert_empty @display.get_data
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
  
  test "returns correct number" do
    @display.categories << @category1
    
    item = FactoryGirl.create(:item, user: @user)
    @category1.items << item
    
    entry = FactoryGirl.create(:entry, item: item, datetime: 5.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    entry = entry.reload
    assert_equal entry.quantity, result
    
    entry2 = FactoryGirl.create(:entry, item: item, datetime: 10.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    entry2 = entry2.reload
    assert_equal (entry.quantity + entry2.quantity)/5.0, result
    
    entry3 = FactoryGirl.create(:entry, item: item, datetime: 20.days.ago)
    result = @display.get_data
    assert_not_nil result
    entry3 = entry3.reload
    
    sum = entry.quantity + entry2.quantity + entry3.quantity
    assert_equal sum.to_f/15.0, result
    
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
    
    entry2 = FactoryGirl.create(:entry, item: item, datetime: 10.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    assert_equal (entry.quantity + entry2.quantity)/5.0, result

    display.start_date = 20.days.ago
    display.save!
    
    result = display.get_data
    assert_equal (entry.quantity + entry2.quantity)/5.0, result
    
    display.start_date = 7.days.ago
    display.save!
    
    result = display.get_data
    assert_equal entry.quantity, result
    
    
  end
end

require 'test_helper'

class AverageTimeBetweenEntryTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @page = FactoryBot.create(:page, user: @user)
    display_type = DisplayTypes::AverageTimeBetweenEntry.first
    if display_type.nil?
      display_type = DisplayTypes::AverageTimeBetweenEntry.new
    end
    display_type.name = 'blah'
    display_type.save!
    @display = FactoryBot.create(:display, display_type: display_type, page: @page)
    @category1 = FactoryBot.create(:category, user: @user)
    @category2 = FactoryBot.create(:category, user: @user)
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
    
    item = FactoryBot.build(:item, user: @user)
    @category1.items << item
    
    assert_nil @display.get_data
  end
  
  test "returns correct time" do
    @display.categories << @category1
    
    item = FactoryBot.create(:item, user: @user)
    @category1.items << item
    
    entry = FactoryBot.create(:entry, item: item, datetime: 5.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    assert_equal 0, result
    
    entry2 = FactoryBot.create(:entry, item: item, datetime: 10.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    assert_equal 5, result
    
    entry3 = FactoryBot.create(:entry, item: item, datetime: 20.days.ago)
    result = @display.get_data
    assert_not_nil result
    assert_equal 7.5, result
    
  end

  test "start date constraints" do
    category = FactoryBot.create(:category, user: @user)
    display = @page.displays.first
    display.categories << category
    display.start_date = 1.days.ago

    item = FactoryBot.create(:item, user: @user)
    category.items << item
    
    entry = FactoryBot.create(:entry, item: item, datetime: 5.days.ago)
    
    result = display.get_data
    assert_nil result
    
    entry2 = FactoryBot.create(:entry, item: item, datetime: 10.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    assert_equal 5, result

    display.start_date = 20.days.ago
    display.save!
    
    result = display.get_data
    assert_equal 5, result
    
    display.start_date = 7.days.ago
    display.save!
    
    result = display.get_data
    assert_equal 0, result
    
    
  end
end

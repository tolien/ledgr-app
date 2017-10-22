require 'test_helper'

class PieChartTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @page = FactoryBot.create(:page, user: @user)
    display_type = DisplayTypes::PieChart.first
    if display_type.nil?
        display_type = DisplayTypes::PieChart.new
    end
    display_type.name = 'pie'
    display_type.save!
    @display = FactoryBot.create(:display, display_type: display_type, page: @page)
    @category1 = FactoryBot.create(:category, user: @user)
    @category2 = FactoryBot.create(:category, user: @user)
  end

  test "if there are no categories should return empty list" do
    assert_empty @display.get_data
  end
  
  test "if categories have no items should return empty" do
    @display.categories << @category1
    @display.save!
    
    assert_empty @display.get_data
  end
  
  test "if items have no entries should return empty" do
    @display.categories << @category1
    @display.save!
    
    item = FactoryBot.build(:item, user: @user)
    @category1.items << item
    
    assert_empty @display.get_data
  end
  
  test "start date constraints" do
    category = FactoryBot.create(:category, user: @user)
    display = @page.displays.first
    display.categories << category
    display.start_date = 1.days.ago

    item = FactoryBot.create(:item, user: @user)
    category.items << item
    
    entry = FactoryBot.create(:entry, item: item, datetime: 5.days.ago)
    entry.reload
    
    result = display.get_data
    assert_empty result
    
    entry2 = FactoryBot.create(:entry, item: item, datetime: 10.days.ago)
    entry2.reload

    item.reload
    item.entries.reload
        
    # default start date is 1 month ago so expect to see something for @display
    result = @display.get_data
    assert_not_nil result
    assert_equal 1, result.size
    assert_equal item.id, result.first.id
    assert_equal item.name, result.first.name
    assert_in_delta item.total, result.first.sum, 0.00001

    display.start_date = 20.days.ago
    display.save!
    
    result = display.get_data
    assert_equal 1, result.size
    assert_in_delta item.total, result.first.sum, 0.00001
    
    display.start_date = 7.days.ago
    display.save!
    
    result = display.get_data
    assert_equal 1, result.size
    assert_in_delta entry.quantity, result.first.sum, 0.00001
    
    
  end

  test "end date constraints" do
    category = FactoryBot.create(:category, user: @user)
    display = @page.displays.first
    display.categories << category
    display.end_date = 5.days.ago

    item = FactoryBot.create(:item, user: @user)
    category.items << item
    
    entry = FactoryBot.create(:entry, item: item, datetime: 1.days.ago)
    entry.reload
    
    result = display.get_data
    assert_empty result
    
    entry2 = FactoryBot.create(:entry, item: item, datetime: 10.days.ago)
    entry2.reload

    item.reload
    item.entries.reload
        
    # default start date is 1 month ago so expect to see item returned
    result = @display.get_data
    assert_not_nil result
    assert_equal 1, result.size
    assert_equal item.id, result.first.id
    assert_equal item.name, result.first.name
    assert_in_delta item.total, result.first.sum, 0.00001

    display.end_date = DateTime.now
    display.save!
    
    result = display.get_data
    assert_equal 1, result.size
    assert_in_delta item.total, result.first.sum, 0.00001
    
    display.start_date = 7.days.ago
    display.save!
    
    result = display.get_data
    assert_equal 1, result.size
    assert_in_delta entry.quantity, result.first.sum, 0.00001
    
    
  end
end

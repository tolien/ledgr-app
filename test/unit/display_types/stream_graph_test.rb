require 'test_helper'

class StreamGraphTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @page = FactoryGirl.create(:page, user: @user)
    display_type = DisplayTypes::StreamGraph.first
    if display_type.nil?
      display_type = DisplayTypes::StreamGraph.new
      display_type.name = 'Streamgraph'
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
  
  test "returns correct result" do
    @display.categories << @category1
    
    item = FactoryGirl.create(:item, user: @user)
    @category1.items << item
    
    entry = FactoryGirl.create(:entry, item: item, datetime: 5.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    assert_equal 1, result.keys.size
    assert_equal entry.datetime.utc.at_beginning_of_month, result.keys.first
    assert_equal 1, result[result.keys.first].size
    assert_equal item.id, result[result.keys.first].first[:item_id]
    assert_equal entry.quantity, result[result.keys.first].first[:value]
    
    entry2 = FactoryGirl.create(:entry, item: item, datetime: 10.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    assert_equal 1, result.keys.size
    assert_equal entry.datetime.utc.at_beginning_of_month, result.keys.first
    assert_equal 1, result[result.keys.first].size
    assert_equal item.id, result[result.keys.first].first[:item_id]
    assert_equal entry.quantity + entry2.quantity, result[result.keys.first].first[:value]
    
    
    entry3 = FactoryGirl.create(:entry, item: item, datetime: 20.days.ago)
    result = @display.get_data
    
  end

  test "start date constraints" do
    
    
  end
  
  test "date truncation" do
    assert_equal "2017-05-01 00:00:00 +0100".to_datetime, @display.display_type.date_trunc(:month, "2017-05-21 23:34:10 +0100".to_datetime)
  end
  
  
end

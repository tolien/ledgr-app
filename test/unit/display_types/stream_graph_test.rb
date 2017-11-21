require 'test_helper'

class StreamGraphTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @page = FactoryBot.create(:page, user: @user)
    display_type = DisplayTypes::StreamGraph.first
    if display_type.nil?
      display_type = DisplayTypes::StreamGraph.new
      display_type.name = 'Streamgraph'
      display_type.save!
    end
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
  
  test "returns correct result" do
    @display.categories << @category1
    
    item = FactoryBot.create(:item, user: @user)
    @category1.items << item
    
    entry = FactoryBot.create(:entry, item: item, datetime: 5.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    assert_equal 1, result.size
    
    rounded_time = DateTime.now - ((DateTime.now.to_datetime - 5.days.ago.to_datetime).ceil / 3) * 3.days
    #assert_equal rounded_time, result.first[:date]
    assert_equal item.id, result.first[:item_id]
    assert_in_delta entry.quantity, result.first[:value], 0.00001
    
    
    entry2 = FactoryBot.create(:entry, item: item, datetime: 10.days.ago)
    
    result = @display.get_data
    assert_not_nil result
    assert_equal 2, result.size
    result.each do |result_point|
      #rounded_time = DateTime.now - ((DateTime.now.to_datetime - entry.datetime.utc).ceil / 4) * 4.days
      #assert_equal rounded_time, result_point[:date].to_datetime
    end
    assert_equal item.id, result.first[:item_id]
    #assert_in_delta entry.quantity + entry2.quantity, result.first[:value], 0.00001
    
    
    entry3 = FactoryBot.create(:entry, item: item, datetime: 20.days.ago)
    result = @display.get_data
    
  end

  test "date range" do
    @display.categories << @category1
    
    item = FactoryBot.create(:item, user: @user)
    @category1.items << item
    
    entry = FactoryBot.create(:entry, item: item, datetime: 5.days.ago)

    @display.start_date = nil
    @display.end_date = nil
    @display.start_days_from_now = 5

    assert 1, @display.get_data.size

    @display.start_days_from_now = 1
    assert_nil @display.get_data
  end
  
  test "date truncation" do
    now = DateTime.now.to_datetime.utc
    assert_equal now.at_beginning_of_hour, @display.display_type.date_trunc(Time.at(0), 1, now)
    
    test_date = "2017-06-21 00:28:42 +0100".to_datetime.utc
    assert_equal (test_date - 6.days).beginning_of_day.to_datetime, @display.display_type.date_trunc(Time.at(0), 3 * 24, (test_date - 5.days).to_datetime.utc).utc.to_datetime
    assert_equal "2017-05-21 00:00:00 UTC".to_datetime, @display.display_type.date_trunc(Time.at(0), 24, "2017-05-21 23:34:10 +0100".to_datetime).utc
    
    future_time = (DateTime.now + 1.week).utc
    assert_equal Time.now.utc.at_beginning_of_day, @display.display_type.date_trunc(Time.at(0), 24, future_time)
    
    close_time = DateTime.now.at_beginning_of_day + 1.hour
    travel_to close_time - 1.hour
    result = @display.display_type.date_trunc(Time.at(0), 24, close_time)
    travel_back
    assert_equal (close_time.utc - 1.day).at_beginning_of_day, result
  end
  
  
end

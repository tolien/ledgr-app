require "test_helper"

class DayAverageTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.create(:user)
    @page = FactoryBot.create(:page, user: @user)
    display_type = DisplayTypes::DayAverage.first
    if display_type.nil?
      display_type = DisplayTypes::DayAverage.new
      display_type.name = "Entries Per Day"
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

  test "returns correct number" do
    @display.categories << @category1

    item = FactoryBot.create(:item, user: @user)
    @category1.items << item

    entry = FactoryBot.create(:entry, item: item, datetime: 5.days.ago)

    result = @display.get_data
    assert_not_nil result
    assert_in_delta entry.quantity, result, 0.00001

    entry2 = FactoryBot.create(:entry, item: item, datetime: 10.days.ago)

    result = @display.get_data
    assert_not_nil result
    date_delta = (entry.datetime - entry2.datetime) / (24 * 60 * 60)
    assert_in_delta (entry.quantity + entry2.quantity) / date_delta, result, 0.00001

    entry3 = FactoryBot.create(:entry, item: item, datetime: 20.days.ago)
    result = @display.get_data
    assert_not_nil result

    sum = entry.quantity + entry2.quantity + entry3.quantity
    date_delta = (entry.datetime - entry3.datetime) / (24 * 60 * 60)
    assert_in_delta (sum / date_delta), result, 0.00001
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
    date_delta = (entry.datetime - entry2.datetime) / (24 * 60 * 60)
    assert_in_delta (entry.quantity + entry2.quantity) / date_delta, result, 0.00001

    display.start_date = 20.days.ago
    display.save!

    result = display.get_data
    # don't need to update date_delta because there are no new entries
    assert_in_delta (entry.quantity + entry2.quantity) / date_delta, result, 0.00001

    display.start_date = 7.days.ago
    display.save!

    result = display.get_data
    assert_in_delta entry.quantity, result, 0.00001
  end
end

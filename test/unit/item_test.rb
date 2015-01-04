require 'test_helper'
require 'securerandom'

class ItemTest < ActiveSupport::TestCase
  setup do
    @user_one = FactoryGirl.create(:user)
    @user_two = FactoryGirl.create(:user)
    
    @drinks = FactoryGirl.create(:category)
    @water = FactoryGirl.create(:item)
    @water.categories << @drinks
    
    @item_with_no_entries = FactoryGirl.create(:item)
  end
  
  test "item validation" do
    item = Item.create
    assert item.invalid?
    assert item.errors[:user].include?("can\'t be blank")
    assert item.errors[:name].include?("can\'t be blank")
    
    item.name = SecureRandom.base64(5)
    assert item.invalid?
    assert item.errors[:name].empty?
    
    item.user_id = @user_one.id
    item.valid?
  end
  
  test "item with no categories is valid" do
    item = Item.create(name: 'test item')
    item.user_id = @user_one.id
    assert item.valid?
  end
  
  test "an item may only be a member of a category once" do
    assert @water.categories.include?(@drinks), "water is already a member of drinks"
    water = @water
    assert_raises ActiveRecord::RecordInvalid do
      water.categories << @drinks
    end
  end
  
  test "two users can have an item with the same name" do
    assert @water.user_id = @user_one.id
    water = @water.dup
    water.user_id = @user_two.id
    assert water.valid?
  end
  
  test "item return instance or create new" do
    item_name = SecureRandom.base64(5)
    assert_nil Item.find_by_name(item_name), "item shouldn't already exist"
    
    item = Item.find_or_create_by_user_and_name(@user_one, item_name)
    assert_not_nil item
  end
  
  test "sum of all entries" do
    item = @item_with_no_entries
    
    assert item.entries.empty?
    assert_equal 0, item.total, "total should be zero if the item has no entries"
    
    entry = Entry.create
    entry.item_id = item.id
    entry.quantity = 0
    entry.datetime = DateTime.current
    
    item.entries << entry
    assert_equal 0, item.total, "adding a 0-quantity item should leave the total unchanged"
    
    entry = Entry.create
    entry.item_id = item.id
    entry.quantity = 1
    entry.datetime = DateTime.current
    
    item.entries << entry
    assert_equal 1, item.total, "adding an item with a >1 quantity should increase the total"
    
    entry = Entry.create
    entry.item_id = item.id
    entry.quantity = -2
    entry.datetime = DateTime.current
    
    item.entries << entry
    assert_equal -1, item.total, "adding an item with a <0 quantity should decrease the total by that much"
  end
end

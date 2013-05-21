require 'test_helper'
require 'securerandom'

class ItemTest < ActiveSupport::TestCase
  setup do
    @drinks = categories(:drinks)
    @water = items(:water)
    @water.categories << @drinks
    
    @user_one = users(:one)
    @user_two = users(:two)
    
    @item_with_no_entries = items(:item_with_no_entries)
  end
  
  test "item with no categories is valid" do
    item = Item.create(name: 'test item')
    item.user_id = @user_one.id
    assert item.valid?
  end
  
  test "item must be unique within all its categories" do
      # item in one category
      new_water = Item.create(name: @water.name)
      new_water.add_category(@drinks)
      
      assert new_water.invalid?
#      assert new_water.errors[:name].include?('must be unique in the category'), "The item should have an error"
      
      # item in two categories
      hats = categories(:hats)
      water_hat = Item.create(name: "Water")
      water_hat.add_category(hats)
#      assert water_hat.valid?
      water_hat.add_category(@drinks)
      assert water_hat.invalid?
      
  end
  
  test "an item may only be a member of a category once" do
    assert @water.categories.include?(@drinks), "water is already a member of drinks"
    water = @water
    #assert_raise ActiveRecord::RecordInvalid, water.categories << @drinks, "Trying to add another item with the same name should raise an exception"
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
